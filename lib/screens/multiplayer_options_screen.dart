import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/widgets/animated_button.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:chain_reaction_game/widgets/positional_back_button.dart';

class MultiPlayerOptionsScreen extends StatelessWidget {
  MultiPlayerOptionsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/group.png', width: 150.0),
                  SizedBox(height: 20.0),
                  SizedBox(
                    width: 200.0,
                    height: 60.0,
                    child: AnimatedButton(
                      child:
                          Text('Play Offline', style: AppTextStyles.buttonText),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.multi_player_offline);
                      },
                    ),
                  ),
                  SizedBox(height: 30.0),
                  SizedBox(
                    width: 200.0,
                    height: 60.0,
                    child: AnimatedButton(
                      child:
                          Text('Play Online', style: AppTextStyles.buttonText),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.multi_player_online);
                      },
                    ),
                  ),
                ],
              ),
            ),
            PositionalBackButton(),
          ],
        ),
      ),
    );
  }
}
