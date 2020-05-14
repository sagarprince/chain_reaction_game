import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';

class Orb extends StatelessWidget {
  final String color;
  final double width;
  final double height;
  final double radius;
  final bool isSelected;

  Orb(
      {Key key,
      this.color = 'red',
      this.width = 50,
      this.height = 50,
      this.radius = 22,
      this.isSelected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: DrawOrb(color: color, radius: radius, isSelected: isSelected),
    );
  }
}

class DrawOrb extends CustomPainter {
  final String color;
  final double radius;
  final bool isSelected;

  DrawOrb({this.color, this.radius, this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    double x = size.width / 2;
    double y = size.height / 2;
    Rect circleRect = new Rect.fromCircle(
      center: new Offset(x, y),
      radius: 12.0,
    );

    Color playerColor = AppColors.getColorByName(color);

    var _gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment(0.5, 1.0),
      colors: [
        playerColor,
        AppColors.darken(playerColor, 0.35)
      ], // whitish to gray
      tileMode: TileMode.clamp,
    );

    if (isSelected) {
      final Paint paintOutline = new Paint()
        ..color = Colors.white
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(x, y), radius, paintOutline);
    }

    final Paint paint = new Paint()
      ..color = Colors.white
      ..strokeWidth = 10.0
      ..shader = _gradient.createShader(circleRect);
    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
