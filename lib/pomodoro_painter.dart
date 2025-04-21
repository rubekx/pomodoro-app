import 'package:flutter/material.dart';

class PomodoroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = Colors.red;

    // Corpo da maçã
    final appleBody = Path()
      ..moveTo(center.dx - 80, center.dy)
      ..cubicTo(center.dx - 220, center.dy - 200, center.dx + 220, center.dy - 200, center.dx + 80, center.dy)
      ..cubicTo(center.dx + 100, center.dy + 120, center.dx - 100, center.dy + 120, center.dx - 80, center.dy)
      ..close();

    canvas.drawPath(appleBody, paint);

    // Folha
    final leafPaint = Paint()..color = Colors.green;
    final leafPath = Path()
      ..moveTo(center.dx, center.dy - 180)
      ..quadraticBezierTo(center.dx + 90, center.dy - 200, center.dx + 130, center.dy - 170)
      ..quadraticBezierTo(center.dx + 70, center.dy - 120, center.dx, center.dy - 170)
      ..close();
    canvas.drawPath(leafPath, leafPaint);

    // Cabo
    final stemPaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 10;
    canvas.drawLine(center.translate(0, -120), center.translate(0, -190), stemPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
