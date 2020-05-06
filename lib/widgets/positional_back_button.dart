import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';

class PositionalBackButton extends StatelessWidget {
  PositionalBackButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 10,
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.white, size: 32.0),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.maybePop(context);
          }
        },
      ),
    );
  }
}
