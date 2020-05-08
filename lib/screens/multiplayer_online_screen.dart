import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:chain_reaction_game/widgets/animated_button.dart';
import 'package:chain_reaction_game/widgets/positional_back_button.dart';

class MultiPlayerOnlineScreen extends StatelessWidget {
  MultiPlayerOnlineScreen({Key key}) : super(key: key);

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
                  Image.asset('assets/images/online.png', width: 100.0),
                  SizedBox(height: 30.0),
                  SizedBox(
                    width: 200.0,
                    height: 50.0,
                    child: AnimatedButton(
                      child:
                          Text('Create Game', style: AppTextStyles.buttonText),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            AppRoutes.multi_player_online_create_game);
                      },
                    ),
                  ),
                  SizedBox(height: 30.0),
                  SizedBox(
                    width: 200.0,
                    height: 50.0,
                    child: AnimatedButton(
                      child: Text('Join Game', style: AppTextStyles.buttonText),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.multi_player_online_join_game);
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
