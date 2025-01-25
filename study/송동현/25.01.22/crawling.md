## 클라이밍장 크롤롤링 코드
```
import sys
import random

# selenium의 webdriver를 사용하기 위한 import
from selenium import webdriver

# 크롬 드라이버의 시작과 중지를 담당하는 서비스 클래스
from selenium.webdriver.chrome.service import Service as ChromeService

# 웹의 버전과 dirver의 버전 관리 해주는 라이브러리
from webdriver_manager.chrome import ChromeDriverManager

# 페이지가 완전히 로딩되기 까지 기다릴 수 있게 하는 라이브러리
from selenium.webdriver.support.ui import WebDriverWait

# 브라우저 자동 꺼짐 방지 옵션
from selenium.webdriver.chrome.options import Options

# 조건을 설정하고 조건에 부합하는지 판단하는 라이브러리
from selenium.webdriver.support import expected_conditions as EC

# selenium으로 무엇인가 입력하기 위한 import (키보드)
from selenium.webdriver.common.keys import Keys

# 확인하려는 요소가 어떤 속성인지 정의해 확인할 수 있도록 하는 라이브러리
from selenium.webdriver.common.by import By

# 
from selenium.webdriver.common.action_chains import ActionChains

# 페이지 로딩을 기다리는데에 사용할 time 모듈 import
from time import sleep

import re

from pprint import pprint

import json
import csv 

from selenium.common.exceptions import NoSuchElementException

options = webdriver.ChromeOptions()
options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3')
options.add_argument('window-size=1380,900')
driver = webdriver.Chrome(options=options)

# 대기 시간
driver.implicitly_wait(time_to_wait=3)
 
# 반복 종료 조건
loop = True

climb_list = []

def save_to_csv(climb_list, filename):
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        # CSV 헤더 쓰기
        writer.writerow(climb_list[0].keys())
        # 데이터 쓰기
        for climb in climb_list:
            writer.writerow(climb.values())

def save_to_json(climb_list, filename):
    with open(filename, 'w', encoding='utf-8') as file:
        # JSON 데이터 쓰기, 인덴트는 4로 설정하여 가독성 향상
        json.dump(climb_list, file, ensure_ascii=False, indent=4)

def switch_left():
    ############## iframe으로 왼쪽 포커스 맞추기 ##############
    driver.switch_to.parent_frame()
    iframe = driver.find_element(By.XPATH,'//*[@id="searchIframe"]')
    driver.switch_to.frame(iframe)
    
def switch_right():
    ############## iframe으로 오른쪽 포커스 맞추기 ##############
    driver.switch_to.parent_frame()
    iframe = driver.find_element(By.XPATH,'//*[@id="entryIframe"]')
    driver.switch_to.frame(iframe)

url ='https://map.naver.com/p/search/%ED%81%B4%EB%9D%BC%EC%9D%B4%EB%B0%8D?searchType=place&c=13.00,0,0,0,dh'

driver.get(url=url)


try:
    while(True):
        switch_left()

        # 페이지 숫자를 초기에 체크 [ True / False ]
        # 이건 페이지 넘어갈때마다 계속 확인해줘야 함 (페이지 새로 로드 될때마다 버튼 상태 값이 바뀜)
        next_page = driver.find_element(By.XPATH,'//*[@id="app-root"]/div/div[2]/div[2]/a[7]').get_attribute('aria-disabled')

        print('다음페이지',next_page)

        ############## 맨 밑까지 스크롤 ##############
        # 일단 맨밑까지 스크롤해서 데이터들이 모두 로드 될 수 있도록 해줘야함 
        scrollable_element = driver.find_element(By.CLASS_NAME, "Ryr1F")
    
        last_height = driver.execute_script("return arguments[0].scrollHeight", scrollable_element)
    
        while True:
            # 요소 내에서 아래로 600px 스크롤
            driver.execute_script("arguments[0].scrollTop += 1000;", scrollable_element)
    
            # 페이지 로드를 기다림
            sleep(1)  # 동적 콘텐츠 로드 시간에 따라 조절
    
            # 새 높이 계산
            new_height = driver.execute_script("return arguments[0].scrollHeight", scrollable_element)
    
            # 스크롤이 더 이상 늘어나지 않으면 루프 종료
            if new_height == last_height:
                break
    
            last_height = new_height


        ############## 현재 page number 가져오기 - 1 페이지 ##############
    
        page_no = driver.find_element(By.XPATH,'//a[contains(@class, "mBN2s qxokY")]').text
    
        # 현재 페이지에 등록된 모든 가게 조회
        # 첫페이지 광고 2개 때문에 첫페이지는 앞 2개를 빼야함
        # if(page_no == '1'):
        #     elemets = driver.find_elements(By.XPATH,'//*[@id="_pcmap_list_scroll_container"]//li')[2:]
        # else:
        #     elemets = driver.find_elements(By.XPATH,'//*[@id="_pcmap_list_scroll_container"]//li')
    
        elemets = driver.find_elements(By.XPATH,'//*[@id="_pcmap_list_scroll_container"]//li')
        
        print('현재 ' + '\033[95m' + str(page_no) + '\033[0m' + ' 페이지 / '+ '총 ' + '\033[95m' + str(len(elemets)) + '\033[0m' + '개의 가게를 찾았습니다.\n')
        for index, e in enumerate(elemets, start=1):

            climb_ground = {}
            try:
                final_element = WebDriverWait(e, 10).until(
                    EC.presence_of_element_located((By.XPATH, f'//*[@id="_pcmap_list_scroll_container"]/ul/li[{index}]/div[1]/div[2]/a[1]/div/div/span[1]'))
                )
            except:
                final_element = WebDriverWait(e, 10).until(
                    EC.presence_of_element_located((By.XPATH, f'//*[@id="_pcmap_list_scroll_container"]/ul/li[{index}]/div[1]/div/a[1]/div/div/span[1]'))
                )
            
            print("클라이밍장이름 : ", final_element.text)

            climb_ground['클라이밍장이름']= final_element.text
            try :
                image_element = WebDriverWait(driver, 20).until(
                    EC.presence_of_element_located((By.XPATH, f'//*[@id="_pcmap_list_scroll_container"]/ul/li[{index}]/div[1]/div[1]/a/img'))
                )
                climb_ground['이미지url'] = image_element.get_attribute('src')
            except:
                climb_ground['이미지url'] = '없음'

            print("이미지 url : ", climb_ground['이미지url'])
            # print(str(index) + ". " + final_element.text)
            # print(climb_ground)

            final_element.click()

            switch_right()

            ################### 여기부터 크롤링 시작 ##################
            
            title = driver.find_element(By.XPATH,'//div[@class="zD5Nm undefined"]')

            # 카테고리
            category = title.find_element(By.XPATH,'.//div[1]/div[1]/span[2]').text
            
            if category == '기업':
                print('클라이밍장 아님')
                switch_left()
                continue
            
            print('카테고리 :', category )

            climb_ground['카테고리'] = category
            
            # 가게 주소
            address = driver.find_element(By.XPATH,'//span[@class="LDgIH"]').text
            print('가게 주소 :', address )

            climb_ground['주소'] = address

            try:
                business_hours=[]
                driver.find_element(By.XPATH,'//div[@class="y6tNq"]//span').click()
    
                # 영업 시간 더보기 버튼을 누르고 2초 반영시간 기다림
                sleep(2)
    
                parent_element = driver.find_element(By.XPATH,'//a[@class="gKP9i RMgN0"]')
                child_elements = parent_element.find_elements(By.XPATH, './*[@class="w9QyJ" or @class="w9QyJ undefined"]')
    
                for child in child_elements:
                    # 각 자식 요소 내에서 클래스가 'A_cdD'인 span 요소 찾기
                    span_elements = child.find_elements(By.XPATH, './/span[@class="A_cdD"]')
    
                    # 찾은 span 요소들의 텍스트 출력
                    for span in span_elements:
                        business_hours.append(span.text)
                
                climb_ground['영업 시간'] = business_hours

            except:
                print('------------ 영업시간 오류')
                climb_ground['영업 시간'] = '확인 불가'

            print('영업시간 : ', business_hours)

            # try :
            #     image_element = WebDriverWait(driver, 7).until(
            #         EC.presence_of_element_located((By.XPATH, '/html/body/div[3]/div/div[1]/div/div/img'))
            #     )
            #     climb_ground['가격표url'] = image_element.get_attribute('src')
            # except:
            #     climb_ground['가격표url'] = '없음'
            
            # print('가격표 url', climb_ground['가격표url'] )
            
            
            # 전화번호
            try:
                # 바로 번호가 뜨는 경우
                phone_num = driver.find_element(By.XPATH,'//span[@class="xlx7Q"]').text
            except:
                # 눌러서 찾아야 하는 경우
                # 번호를 클릭해야 나타나는 경우
                try:
                    # 클릭할 요소 찾기
                    clickable_element = WebDriverWait(driver, 10).until(
                        EC.element_to_be_clickable((By.CLASS_NAME, 'BfF3H'))  # 클릭할 요소의 실제 클래스 이름으로 변경하세요
                    )
                    clickable_element.click()
                    
                    # 클릭 후 전화번호가 나타나길 기다림
                    # 전화번호가 나타나길 기다림 - 첫 번째 경로 시도
                    try:
                        phone_num = WebDriverWait(driver, 5).until(
                            EC.visibility_of_element_located((By.XPATH, '//*[@id="app-root"]/div/div/div/div[5]/div/div[2]/div[1]/div/div[4]/div/div/div/div/em'))
                        ).text
                    except:
                        # 첫 번째 경로 실패 시, 두 번째 경로 시도
                        phone_num = WebDriverWait(driver, 5).until(
                            EC.visibility_of_element_located((By.XPATH, '//*[@id="app-root"]/div/div/div/div[5]/div/div[2]/div[1]/div/div[3]/div/div/div/div/em'))
                        ).text
                except Exception as e:
                    print(f"Failed to retrieve phone number after click: {e}")
                    phone_num = '번호 없음'

            print('전화번호 :' , phone_num)
            climb_ground['전화번호'] = phone_num

            # try:
            #     j009N_link = WebDriverWait(driver, 10).until(
            #         EC.presence_of_element_located((By.CSS_SELECTOR, ".j009N a"))
            #     ).get_attribute('href')
            #     print("j009N class link:", j009N_link)
            #     climb_ground['site_url']=j009N_link
            # except Exception as e:
            #     print("j009N class link not found:", e)

            # try:
            #     cycl8_elements = WebDriverWait(driver, 10).until(
            #         EC.presence_of_all_elements_located((By.CSS_SELECTOR, ".Cycl8 .S8peq a"))
            #     )
            #     for element in cycl8_elements:
            #         link = element.get_attribute('href')
            #         text = element.text
            #         print("Link:", link, "Text:", text)
            #         climb_ground[text]=link
            # except Exception as e:
            #     print("Cycl8 class elements not found:", e)
            try:
                # 시설정보
                facilites = driver.find_element(By.XPATH,'//div[@class="xPvPE"]').text
            except :
                facilites = '없음'
            
            print("시설정보 :" , facilites)
            climb_ground['시설정보']=facilites

            print(climb_ground)
            switch_left()

        climb_list.append(climb_ground)
        switch_left()

        if(next_page == 'true'):
            break
        # 페이지 다음 버튼이 활성화 상태일 경우 계속 진행
        if(next_page == 'false'):
            driver.find_element(By.XPATH,'//*[@id="app-root"]/div/div[2]/div[2]/a[7]').click()
        # 아닐 경우 루프 정지
        else:
            loop = False

    # CSV 파일로 저장 실행
    save_to_csv(climb_list, 'climb_list.csv')

    # JSON 파일로 저장 실행
    save_to_json(climb_list, 'climb_list.json')
except:
    # CSV 파일로 저장 실행
    save_to_csv(climb_list, 'climb_list.csv')

    # JSON 파일로 저장 실행
    save_to_json(climb_list, 'climb_list.json')

```