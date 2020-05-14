import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/blocs/events.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/blocs/bloc.dart';
import 'package:chain_reaction_game/widgets/animated_button.dart';
import 'package:chain_reaction_game/widgets/positional_back_button.dart';
import 'package:chain_reaction_game/widgets/color_chooser.dart';
import 'package:chain_reaction_game/widgets/background.dart';

class VersusBotScreen extends StatefulWidget {
  VersusBotScreen({Key key}) : super(key: key);
  _VersusBotScreenState createState() => _VersusBotScreenState();
}

class _VersusBotScreenState extends State<VersusBotScreen> {
  String _yourColor = '';
  String _botColor = '';
  bool _isBotChoosingColor = false;

  String getBotColor() {
    int index = Random().nextInt(PlayerColors.length);
    String color = PlayerColors[index];
    if (color == _yourColor) {
      color = getBotColor();
    }
    return color;
  }

  void botChoosingColor() {
    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        _isBotChoosingColor = false;
        _botColor = getBotColor();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double paddingTop = MediaQuery.of(context).padding.top + 60;
    double paddingBottom = 70.0;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    padding:
                        EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Choose Your Color',
                            style: AppTextStyles.mediumText),
                        SizedBox(height: 20.0),
                        ColorChooser(
                          disabled: _isBotChoosingColor,
                          activeColor: _yourColor,
                          onSelection: (String color) {
                            setState(() {
                              _yourColor = color;
                              _isBotChoosingColor = true;
                            });
                            botChoosingColor();
                          },
                        ),
                        SizedBox(height: 40.0),
                        _yourColor != ''
                            ? Text(
                                _isBotChoosingColor ? 'Wait...' : 'Bot Color',
                                style: AppTextStyles.mediumText)
                            : SizedBox(),
                        _yourColor != ''
                            ? ColorChooser(
                                activeColor: _botColor,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 400),
              bottom:
                  (_yourColor != '' && _botColor != '' && !_isBotChoosingColor)
                      ? 10
                      : -200,
              curve: Curves.easeIn,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      width: 200,
                      height: 48.0,
                      child: AnimatedButton(
                          child: Text('START', style: AppTextStyles.buttonText),
                          onPressed: () {
                            BlocProvider.of<CRBloc>(context).add(StartGameEvent(
                                gameMode: GameMode.PlayVersusBot,
                                players: [
                                  Player('You', _yourColor, true),
                                  Player('Bot', _botColor, false),
                                ]));
                            Navigator.of(context)
                                .pushNamed(AppRoutes.play_game);
                          }),
                    )
                  ],
                ),
              ),
            ),
            PositionalBackButton(),
          ],
        ),
      ),
    );
  }
}
