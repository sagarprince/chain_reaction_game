import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';

class PlayGameButton extends StatelessWidget {
  final IconData icon1;
  final IconData icon2;
  final VoidCallback onPressed;

  PlayGameButton(
      {Key key, @required this.icon1, @required this.icon2, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 2,
      padding: EdgeInsets.all(0.0),
      minWidth: 70.0,
      child: Container(
        width: 70.0,
        height: 70.0,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: AppColors.cardinal,
              width: 3.0,
            )),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              top: 5,
              child: Icon(
                icon1,
                color: AppColors.cardinal,
                size: 50.0,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Icon(
                icon2,
                size: 22.0,
                color: AppColors.cardinal,
              ),
            )
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }
}
