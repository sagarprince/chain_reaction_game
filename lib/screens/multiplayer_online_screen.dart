import 'package:chain_reaction_game/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:chain_reaction_game/widgets/positional_back_button.dart';

class MultiPlayerOnlineScreen extends StatefulWidget {
  MultiPlayerOnlineScreen({Key key}) : super(key: key);

  _MultiPlayerOnlineScreenState createState() =>
      _MultiPlayerOnlineScreenState();
}

class _MultiPlayerOnlineScreenState extends State<MultiPlayerOnlineScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Background(
        child: Stack(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Coming Soon...',
                          style:
                              AppTextStyles.boldText.copyWith(fontSize: 26.0))
                    ],
                  )
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
