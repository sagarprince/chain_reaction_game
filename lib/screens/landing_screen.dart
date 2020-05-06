import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/utils/ui_utils.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:chain_reaction_game/widgets/play_game_button.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                        ),
                        SizedBox(height: 30.0),
                        Text('CHAIN', style: AppTextStyles.landingHeadingText),
                        Text(
                          'REACTION',
                          style: AppTextStyles.landingHeadingText,
                        ),
                        SizedBox(height: 60.0),
                        Row(
                          children: <Widget>[
                            PlayGameButton(
                              icon1: Icons.play_arrow,
                              icon2: Icons.computer,
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.versus_bot);
                              },
                            ),
                            SizedBox(width: 40.0),
                            PlayGameButton(
                              icon1: Icons.play_arrow,
                              icon2: Icons.group,
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.multi_player);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 30.0),
                      ],
                    )
                  ],
                )
              ],
            ),
            Positioned(
              top: 40,
              right: 15,
              child: IconButton(
                icon: Image.asset(
                  'assets/images/rules.png',
                ),
                iconSize: 34.0,
                onPressed: () {
                  UiUtils.showGameRulesDialog(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
