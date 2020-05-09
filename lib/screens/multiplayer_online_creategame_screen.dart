import 'package:chain_reaction_game/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/utils/ui_utils.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/game_socket.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:chain_reaction_game/widgets/positional_back_button.dart';
import 'package:chain_reaction_game/widgets/animated_button.dart';
import 'package:chain_reaction_game/widgets/color_chooser.dart';

class MultiPlayerOnlineCreateGameScreen extends StatefulWidget {
  MultiPlayerOnlineCreateGameScreen({Key key}) : super(key: key);
  _MultiPlayerOnlineCreateGameState createState() =>
      _MultiPlayerOnlineCreateGameState();
}

class _MultiPlayerOnlineCreateGameState
    extends State<MultiPlayerOnlineCreateGameScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  GameSocket _gameSocket;
  int _roomId = -1;
  int playersCount = 2;
  String name = '';
  String color = '';

  @override
  void initState() {
    super.initState();
    _gameSocket = GameSocket();
    _gameSocket.connect();
    _onSubscriptions();
  }

  void _onSubscriptions() {
    _gameSocket.onSubscribeRespond((response) {
      var gamePlayStatus = response['gamePlayStatus'];
      print(gamePlayStatus);
      if (gamePlayStatus == GamePlayStatus.EXCEPTION) {
        var decoded = response['decoded'];
        var message = decoded['message'];
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text(message)));
      } else {
        print('ROOM ID :- ${_gameSocket.roomId}');
        _roomId = _gameSocket.roomId;
        Navigator.of(context)
            .pushReplacementNamed(AppRoutes.multi_player_online_wait);
      }
    });
  }

  void setPlayersCount(bool isIncrement) {
    setState(() {
      if (isIncrement) {
        if (playersCount < 5) {
          playersCount = playersCount + 1;
        }
      } else {
        if (playersCount > 2) {
          playersCount = playersCount - 1;
        }
      }
    });
  }

  bool _validateForm() {
    final FormState form = _formKey.currentState;
    FocusScope.of(context).requestFocus(new FocusNode());
    if (form != null) {
      return form.validate();
    }
    return false;
  }

  void _handleSubmit() {
    final FormState form = _formKey.currentState;
    if (_validateForm()) {
      form.save();
      _gameSocket.createGame(playersCount, Player(name, color, true));
    }
  }

  @override
  Widget build(BuildContext context) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      key: _scaffoldKey,
      body: Background(
        child: Stack(
          children: <Widget>[
            Container(
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                            height: !UiUtils.isKeyboardOpened(context)
                                ? 20
                                : paddingTop + 40),
                        Column(
                          children: <Widget>[
                            Text('Number of Players',
                                style: AppTextStyles.regularText),
                            SizedBox(height: 15.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 35.0,
                                  height: 35.0,
                                  child: AnimatedButton(
                                      child: Icon(Icons.remove,
                                          size: 30.0, color: AppColors.white),
                                      onPressed: () {
                                        setPlayersCount(false);
                                      }),
                                ),
                                SizedBox(
                                  width: 100.0,
                                  child: Center(
                                    child: Text(playersCount.toString(),
                                        style: AppTextStyles.regularText
                                            .copyWith(fontSize: 24.0)),
                                  ),
                                ),
                                SizedBox(
                                  width: 35.0,
                                  height: 35.0,
                                  child: AnimatedButton(
                                    child: Icon(Icons.add,
                                        size: 30.0, color: AppColors.white),
                                    onPressed: () {
                                      setPlayersCount(true);
                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 50.0),
                        Column(
                          children: <Widget>[
                            Text('Enter Your Name',
                                style: AppTextStyles.regularText),
                            SizedBox(height: 10.0),
                            Container(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0),
                              child: TextFormField(
                                maxLength: 24,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.cardinal, width: 2.0),
                                  ),
                                ),
                                cursorColor: AppColors.white,
                                style: AppTextStyles.mediumText,
                                textAlign: TextAlign.center,
                                autovalidate: false,
                                textInputAction: TextInputAction.next,
                                validator: (String value) {
                                  if (value.trim() == '') {
                                    return 'Please enter your name.';
                                  }
                                  return null;
                                },
                                onSaved: (String value) {
                                  name = value;
                                },
                                onFieldSubmitted: (_) {
                                  _validateForm();
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 40.0),
                        FormField(
                          validator: (_) {
                            if (color == '') {
                              return 'Please select color.';
                            }
                            return null;
                          },
                          builder: (FormFieldState field) {
                            return Column(
                              children: <Widget>[
                                Text('Select Your Color',
                                    style: AppTextStyles.regularText),
                                SizedBox(height: 10.0),
                                ColorChooser(
                                  activeColor: color,
                                  onSelection: (String _color) {
                                    setState(() {
                                      color = _color;
                                    });
                                    field.validate();
                                  },
                                ),
                                field.hasError
                                    ? Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: Text(field.errorText,
                                            style: AppTextStyles.formErrorText),
                                      )
                                    : Container(),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            !UiUtils.isKeyboardOpened(context)
                ? AnimatedPositioned(
                    duration: Duration(milliseconds: 400),
                    bottom: 15,
                    curve: Curves.easeIn,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 30.0),
                            width: 180,
                            height: 38.0,
                            child: AnimatedButton(
                                child: Text('CREATE',
                                    style: AppTextStyles.buttonText
                                        .copyWith(fontSize: 16.0)),
                                onPressed: () {
                                  _handleSubmit();
                                }),
                          )
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
            PositionalBackButton(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameSocket.onUnsubscribeRespond();
    if (_roomId == -1) {
      _gameSocket.disconnect();
    }
    super.dispose();
  }
}
