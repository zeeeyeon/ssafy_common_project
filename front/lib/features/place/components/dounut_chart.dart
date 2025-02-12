import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;

class DonutChart extends StatefulWidget {
  final double radius;
  final double strokeWidth;
  final double total;
  final double value;
  final Widget? child;

  DonutChart({
    super.key,
    this.radius = 100,
    this.strokeWidth = 20,
    required this.total,
    required this.value,
    this.child,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _valueAnimation;
  
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _valueAnimation = Tween<double>(
      begin: 0,
      end: (widget.value / widget.total) * 360,
    ).animate(curvedAnimation);

    _controller.addListener(() {
      setState(() {});  // 애니메이션 값이 변경될 때마다 다시 그리도록 `setState` 호출
    });

    _controller.forward();  // 애니메이션 시작
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.radius * 2, widget.radius * 2),  // 원의 크기
      painter: _DonutChartProgressBar(
        strokeWidth: widget.strokeWidth,
        valueProgress: _valueAnimation.value,
      ),
      child: widget.child,  // 추가적인 자식 위젯을 여기에 삽입할 수 있음
    );
  }
}

class _DonutChartProgressBar extends CustomPainter {
  final double strokeWidth;
  final double valueProgress;

  _DonutChartProgressBar({required this.strokeWidth, required this.valueProgress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint defaultPaint = Paint()
      ..color = Color(0xFFE1E1E1)  // 배경색
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    Paint valuePaint = Paint()
      ..color = Color(0xFF7373C9)  // 진행 표시 색상
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);  // 원의 중심 좌표

    // 배경 원 그리기
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2), 
      -pi / 2,  // 시작 각도
      2 * pi,   // 전체 원 (360도)
      false, 
      defaultPaint
    );

    // 진행 상태 원 그리기
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      -pi / 2,  // 시작 각도
      math.radians(valueProgress),  // 진행 각도
      false,
      valuePaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;  // 애니메이션 동안 계속 그려야 하므로 true 반환
  }
}
