import 'package:flutter/material.dart';

class TomatePainter extends StatelessWidget {
  final double size;
  final Color tomatoColor;
  final Color leafColor;

  const TomatePainter({
    super.key,
    this.size = 200,
    this.tomatoColor = const Color(0xFFE53935),
    this.leafColor = const Color(0xFF4CAF50),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _TomatoPainter(tomatoColor: tomatoColor, leafColor: leafColor));
  }
}

class _TomatoPainter extends CustomPainter {
  final Color tomatoColor;
  final Color leafColor;

  _TomatoPainter({required this.tomatoColor, required this.leafColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Adiciona detalhes de sombra no tomate para dar mais volume
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx + radius * 0.3, center.dy + radius * 0.3), radius * 0.75, shadowPaint);
    // Desenha o tomate (corpo principal)
    final tomatoPaint =
        Paint()
          ..color = tomatoColor
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, tomatoPaint);

    // Desenha o caule verde no topo
    final stemPaint =
        Paint()
          ..color = Color(0xFF795548)
          ..style = PaintingStyle.fill;

    final stemRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.9),
      width: size.width * 0.05,
      height: size.height * 0.1,
    );

    canvas.drawRect(stemRect, stemPaint);

    // Desenha as folhas
    final leafPaint =
        Paint()
          ..color = leafColor
          ..style = PaintingStyle.fill;

    // Folha esquerda
    final leftLeafPath = Path();
    leftLeafPath.moveTo(center.dx - size.width * 0.05, center.dy - radius * 0.95);
    leftLeafPath.quadraticBezierTo(
      center.dx - size.width * 0.15,
      center.dy - radius * 1.2,
      center.dx - size.width * 0.25,
      center.dy - radius * 0.95,
    );
    leftLeafPath.quadraticBezierTo(
      center.dx - size.width * 0.15,
      center.dy - radius * 0.75,
      center.dx - size.width * 0.05,
      center.dy - radius * 0.85,
    );
    leftLeafPath.close();
    canvas.drawPath(leftLeafPath, leafPaint);

    // Folha direita
    final rightLeafPath = Path();
    rightLeafPath.moveTo(center.dx + size.width * 0.05, center.dy - radius * 0.95);
    rightLeafPath.quadraticBezierTo(
      center.dx + size.width * 0.15,
      center.dy - radius * 1.2,
      center.dx + size.width * 0.25,
      center.dy - radius * 0.95,
    );
    rightLeafPath.quadraticBezierTo(
      center.dx + size.width * 0.15,
      center.dy - radius * 0.75,
      center.dx + size.width * 0.05,
      center.dy - radius * 0.85,
    );
    rightLeafPath.close();
    canvas.drawPath(rightLeafPath, leafPaint);

    // Adiciona brilho no tomate
    final highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy - radius * 0.3), radius * 0.4, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
