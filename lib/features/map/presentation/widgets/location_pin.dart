import 'package:flutter/material.dart';

class LocationPin extends StatelessWidget {
  final Color color;
  final double size;

  const LocationPin({
    Key? key,
    required this.color,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PinPainter(color: color),
      ),
    );
  }
}

class PinPainter extends CustomPainter {
  final Color color;

  PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final double width = size.width;
    final double height = size.height;
    
    final Path path = Path();
    
    // Draw the pin shape
    path.moveTo(width / 2, height);
    path.lineTo(0, height * 0.6);
    path.quadraticBezierTo(0, height * 0.35, width / 2, height * 0.35);
    path.quadraticBezierTo(width, height * 0.35, width, height * 0.6);
    path.close();
    
    // Draw the circle at the top
    final circlePath = Path();
    circlePath.addOval(Rect.fromCircle(
      center: Offset(width / 2, height * 0.35),
      radius: width * 0.3,
    ));
    
    // Combine paths
    path.addPath(circlePath, Offset.zero);
    
    // Draw shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.5), 4, true);
    
    // Draw pin
    canvas.drawPath(path, paint);
    
    // Draw inner circle (white)
    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(width / 2, height * 0.35),
      width * 0.15,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 