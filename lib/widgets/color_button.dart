import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';

class ColorButton extends StatelessWidget {
  final String color;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback onPressed;

  ColorButton(
      {Key key,
      this.color = 'red',
      this.width = 50,
      this.height = 50,
      this.isSelected = false,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomPaint(
        size: Size(width, height),
        painter: DrawColorCircle(color: color, isSelected: isSelected),
      ),
      onTap: onPressed,
    );
  }
}

class DrawColorCircle extends CustomPainter {
  final String color;
  final bool isSelected;

  DrawColorCircle({this.color, this.isSelected = false});

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
      canvas.drawCircle(Offset(x, y), 20, paintOutline);
    }

    final Paint paint = new Paint()
      ..color = Colors.white
      ..strokeWidth = 10.0
      ..shader = _gradient.createShader(circleRect);
    canvas.drawCircle(Offset(x, y), 20, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
