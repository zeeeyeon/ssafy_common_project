from PIL import Image
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
import io
import logging
import cv2
import numpy as np
import mediapipe as mp

app = FastAPI()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.5)


def remove_background(image: np.ndarray) -> np.ndarray:
    bg_subtractor = cv2.createBackgroundSubtractorMOG2(detectShadows=False)
    fg_mask = bg_subtractor.apply(image)
    result = cv2.bitwise_and(image, image, mask=fg_mask)
    return result


def detect_wingspan(image: np.ndarray, height: float):
    image_no_bg = remove_background(image)
    rgb_image = cv2.cvtColor(image_no_bg, cv2.COLOR_BGR2RGB)
    results = pose.process(rgb_image)

    if not results.pose_landmarks:
        return {"error": "사람이 감지되지 않았습니다. 전체 몸이 보이도록 조정하세요."}

    landmarks = results.pose_landmarks.landmark
    logger.info("✅ PoseNet에서 사람 감지 완료")

    left_fingertip = landmarks[mp_pose.PoseLandmark.LEFT_INDEX]
    right_fingertip = landmarks[mp_pose.PoseLandmark.RIGHT_INDEX]
    head = landmarks[mp_pose.PoseLandmark.NOSE]
    left_ankle = landmarks[mp_pose.PoseLandmark.LEFT_ANKLE]
    right_ankle = landmarks[mp_pose.PoseLandmark.RIGHT_ANKLE]

    if not all([left_fingertip.visibility > 0.5, right_fingertip.visibility > 0.5]):
        return {"error": "손끝 키포인트가 감지되지 않았습니다. 팔을 완전히 벌려주세요."}

    if not all([head.visibility > 0.5, left_ankle.visibility > 0.5, right_ankle.visibility > 0.5]):
        return {"error": "신체 키포인트 감지가 충분하지 않습니다. 카메라 각도를 조정하세요."}

    img_h, img_w, _ = image.shape
    left_hand_x, left_hand_y = left_fingertip.x * img_w, left_fingertip.y * img_h
    right_hand_x, right_hand_y = right_fingertip.x * img_w, right_fingertip.y * img_h

    pixel_wingspan = np.linalg.norm([left_hand_x - right_hand_x, left_hand_y - right_hand_y])
    pixel_height = np.linalg.norm([head.x * img_w - (left_ankle.x * img_w + right_ankle.x * img_w) / 2,
                                   head.y * img_h - (left_ankle.y * img_h + right_ankle.y * img_h) / 2])

    if pixel_height == 0:
        return {"error": "키 측정 오류. 카메라를 다시 조정하세요."}

    real_wingspan = (pixel_wingspan / pixel_height) * height

    if real_wingspan < height * 0.9 or real_wingspan > height * 1.15:
        return {"error": f"윙스팬 계산 오류. 포즈나 카메라 각도를 조정하세요. (계산된 값: {real_wingspan:.2f}cm)"}

    return round(real_wingspan, 2)


def convert_to_baseline_jpeg(image_bytes):
    try:
        image = Image.open(io.BytesIO(image_bytes))

        output_io = io.BytesIO()
        image.save(output_io, format="JPEG", progressive=False)
        logger.info("✅ JPEG 변환 성공")
        return output_io.getvalue()
    except Exception as e:
        print(f"이미지 변환 실패: {e}")
        return None


@app.post("/fastapi/user/wingspan")
async def calculate_wingspan(file: UploadFile = File(...), height: float = Form(...)):
    file_bytes = await file.read()

    logger.info(f"height: {height}")

    if not file_bytes:
        return JSONResponse(content={"error": "파일을 읽을 수 없습니다."}, status_code=400)

    try:
        converted_bytes = convert_to_baseline_jpeg(file_bytes)

        if not converted_bytes:
            return JSONResponse(content={"error": "이미지 변환 실패. 올바른 JPEG을 업로드하세요."}, status_code=400)

        image = np.frombuffer(converted_bytes, np.uint8)
        image = cv2.imdecode(image, cv2.IMREAD_COLOR)

        if image is None:

            return JSONResponse(content={"error": "올바르지 않은 이미지 파일입니다. JPEG 파일을 업로드하세요."}, status_code=400)
        else:
            logger.info("✅ OpenCV에서 이미지 디코딩 성공")

    except Exception as e:
        return JSONResponse(content={"error": f"이미지를 처리할 수 없습니다: {str(e)}"}, status_code=400)

    wingspan = detect_wingspan(image, height)

    if isinstance(wingspan, dict) and "error" in wingspan:
        return JSONResponse(content=wingspan, status_code=400)

    response_data = {
        "status": {
            "code": 200,
            "message": "사용자의 팔 길이가 측정되었습니다."
        },
        "content": {
            "armSpan": wingspan,
        }
    }

    return JSONResponse(content=response_data, status_code=200)