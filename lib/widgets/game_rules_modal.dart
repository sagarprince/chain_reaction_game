import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';

class GameRulesDialog extends StatelessWidget {
  GameRulesDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0, bottom: 15.0),
      height: 400.0,
      child: Stack(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Text('Rules of the Game', style: AppTextStyles.rulesHeading),
                SizedBox(height: 10.0),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Text(
                            'The objective of Chain Reaction is to take control of the board by eliminating your opponent orbs.',
                            style: AppTextStyles.rulesText),
                        SizedBox(height: 10.0),
                        Text(
                            'It will describing the rules of the two-player (Red and Green) game but this could be generalized to any number of players.',
                            style: AppTextStyles.rulesText),
                        SizedBox(height: 15.0),
                        Text(
                            '1) The gameplay takes place in an m×n board. The most commonly used size of the board is 9×6.',
                            style: AppTextStyles.rulesText),
                        SizedBox(height: 10.0),
                        Text(
                            '2) For each cell in the board, we define a critical mass. The critical mass is equal to the number of orthogonally adjacent cells. That would be 4 for usual cells, 3 for cells in the edge and 2 for cells in the corner.',
                            style: AppTextStyles.rulesText),
                        SizedBox(height: 10.0),
                        Text(
                            '3) All cells are initially empty. The Red and the Green player take turns to place "orbs" of their corresponding colors. The Red player can only place an (red) orb in an empty cell or a cell which already contains one or more red orbs. When two or more orbs are placed in the same cell, they stack up.',
                            style: AppTextStyles.rulesText),
                        SizedBox(height: 10.0),
                        Text(
                            '4) When a cell is loaded with a number of orbs equal to its critical mass, the stack immediately explodes. As a result of the explosion, to each of the orthogonally adjacent cells, an orb is added and the initial cell looses as many orbs as its critical mass. The explosions might result in overloading of an adjacent cell and the chain reaction of explosion continues until every cell is stable.',
                            style: AppTextStyles.rulesText),
                        SizedBox(height: 10.0),
                        Text(
                            '5) When a red cell explodes and there are green cells around, the green cells are converted to red and the other rules of explosions still follow. The same rule is applicable for other colors.',
                            style: AppTextStyles.rulesText),
                        SizedBox(height: 10.0),
                        Text(
                            '6) The winner is the one who eliminates every other players orbs.',
                            style: AppTextStyles.rulesText),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment(1.24, -1.14),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset('assets/images/close.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
