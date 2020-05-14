import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/utils/ui_utils.dart';
import 'package:chain_reaction_game/utils/data_connection_checker.dart';
import 'package:chain_reaction_game/models/server_response.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/game/cr_game_server.dart';
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
  final _formKey = new GlobalKey<FormState>();

  CRGameServer _gameServer;
  StreamSubscription<DataConnectionStatus> _connectionStatus;
  int _roomId = -1;
  int _playersLimit = 2;
  String _yourName = '';
  String _yourColor = '';

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() async {
    _gameServer = CRGameServer();
    _gameServer.connect();
    _gameServer.isInitializeConnection = true;
    _connectionStatus = _gameServer.onDataConnectionWatcher();
  }

  void setPlayersLimit(bool isIncrement) {
    setState(() {
      if (isIncrement) {
        if (_playersLimit < 5) {
          _playersLimit = _playersLimit + 1;
        }
      } else {
        if (_playersLimit > 2) {
          _playersLimit = _playersLimit - 1;
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

  void _validateCreateGameResponse(ServerResponse response) {
    var gamePlayStatus = response.gamePlayStatus;
    if (gamePlayStatus == GamePlayStatus.EXCEPTION) {
      _gameServer.showToast(response.message, Duration(milliseconds: 2000));
    } else {
      _roomId = _gameServer.roomId;
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.multi_player_online_wait);
    }
  }

  void _handleSubmit() async {
    bool isConnected = await _gameServer.isConnected();
    if (isConnected) {
      final FormState form = _formKey.currentState;
      if (_validateForm()) {
        form.save();
        var response = await _gameServer.createGame(
            _playersLimit, Player(_yourName, _yourColor, true));
        _validateCreateGameResponse(response);
      }
    } else {
      _gameServer.showToast(
          'Unable to create game, make sure you are connected to internet.',
          Duration(milliseconds: 2000));
    }
  }

  @override
  Widget build(BuildContext context) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
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
                                        setPlayersLimit(false);
                                      }),
                                ),
                                SizedBox(
                                  width: 100.0,
                                  child: Center(
                                    child: Text(_playersLimit.toString(),
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
                                      setPlayersLimit(true);
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
                                  _yourName = value;
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
                            if (_yourColor == '') {
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
                                  activeColor: _yourColor,
                                  onSelection: (String _color) {
                                    setState(() {
                                      _yourColor = _color;
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
    if (_roomId == -1) {
      _gameServer.disconnect();
    }
    _connectionStatus.cancel();
    super.dispose();
  }
}
