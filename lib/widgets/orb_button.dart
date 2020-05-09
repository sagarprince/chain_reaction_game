import 'package:flutter/material.dart';
import 'package:chain_reaction_game/widgets/orb.dart';

class OrbButton extends StatelessWidget {
  final String color;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback onPressed;

  OrbButton(
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
      child: Orb(
          color: color, width: width, height: height, isSelected: isSelected),
      onTap: onPressed,
    );
  }
}
