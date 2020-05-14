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

class MultiPlayerOnlineJoinGameScreen extends StatefulWidget {
  MultiPlayerOnlineJoinGameScreen({Key key}) : super(key: key);
  _MultiPlayerOnlineJoinGameState createState() =>
      _MultiPlayerOnlineJoinGameState();
}

class _MultiPlayerOnlineJoinGameState
    extends State<MultiPlayerOnlineJoinGameScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  CRGameServer _gameServer;
  StreamSubscription<DataConnectionStatus> _connectionStatus;
  int _roomId = -1;
  String _yourName = '';
  String _yourColor = '';

  String _roomIdError = '';
  String _nameError = '';
  String _colorError = '';

  final FocusNode _roomIdFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();

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

  bool _validateForm() {
    final FormState form = _formKey.currentState;
    FocusScope.of(context).requestFocus(new FocusNode());
    _roomIdError = '';
    _nameError = '';
    _colorError = '';
    if (form != null) {
      return form.validate();
    }
    return false;
  }

  void _validateJoinGameResponse(ServerResponse response) {
    var gamePlayStatus = response.gamePlayStatus;
    if (gamePlayStatus == GamePlayStatus.START) {
      _gameServer.startGame(context);
    } else if (gamePlayStatus == GamePlayStatus.WAIT) {
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.multi_player_online_wait);
    } else if (gamePlayStatus == GamePlayStatus.ERROR) {
      if (response.status == 'error') {
        FormState form = _formKey.currentState;
        var code = response.code;
        var message = response.message;
        if (code == 'invalid_room_id' || code == 'room_full') {
          _roomIdError = message;
        } else if (code == 'name_exist') {
          _nameError = message;
        } else if (code == 'color_exist') {
          _colorError = message;
        }
        form.validate();
      }
    } else {
      var message = response.message;
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _handleSubmit() async {
    bool isConnected = await _gameServer.isConnected();
    if (isConnected) {
      final FormState form = _formKey.currentState;
      if (_validateForm()) {
        form.save();
        var response = await _gameServer.joinGame(
            _roomId, Player(_yourName, _yourColor, true));
        _validateJoinGameResponse(response);
      }
    } else {
      _gameServer.showToast(
          'Unable to join game, make sure you are connected to internet.',
          Duration(milliseconds: 2000));
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
                            Text('Enter Room Code',
                                style: AppTextStyles.regularText),
                            Container(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0),
                              child: TextFormField(
                                focusNode: _roomIdFocusNode,
                                maxLength: 5,
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
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: (dynamic value) {
                                  if (value.trim() == '') {
                                    return 'Please enter room code.';
                                  } else if (_roomIdError != '') {
                                    return _roomIdError;
                                  }
                                  return null;
                                },
                                onSaved: (String value) {
                                  _roomId = int.parse(value);
                                },
                                onFieldSubmitted: (_) {
                                  if (_yourName == '') {
                                    _roomIdFocusNode.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_nameFocusNode);
                                  } else {
                                    _validateForm();
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 30.0),
                        Column(
                          children: <Widget>[
                            Text('Enter Your Name',
                                style: AppTextStyles.regularText),
                            Container(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0),
                              child: TextFormField(
                                focusNode: _nameFocusNode,
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
                                textInputAction: TextInputAction.next,
                                validator: (String value) {
                                  if (value.trim() == '') {
                                    return 'Please enter your name.';
                                  } else if (_nameError != '') {
                                    return _nameError;
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
                        SizedBox(height: 30.0),
                        FormField(
                          validator: (_) {
                            if (_yourColor == '') {
                              return 'Please select color.';
                            } else if (_colorError != '') {
                              return _colorError;
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
                        SizedBox(height: 30.0),
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
                                child: Text('JOIN',
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
