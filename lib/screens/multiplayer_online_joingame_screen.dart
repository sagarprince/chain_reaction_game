import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/utils/ui_utils.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/game_socket.dart';
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
  final joinGameFormKey = new GlobalKey<FormState>();

  GameSocket _gameSocket;
  int roomId = 2;
  String name = '';
  String color = '';
  int playersCount = 2;

  String roomIdError = '';
  String nameError = '';
  String colorError = '';

  final FocusNode _roomIdFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _gameSocket = GameSocket();
    _gameSocket.connect();
    _onSubscriptions();
  }

  void _onSubscriptions() {
    _gameSocket.onSubscribeRespond((data) {
      var gamePlayStatus = data['gamePlayStatus'];
      var decoded = data['decoded'];
      if (gamePlayStatus == GamePlayStatus.START) {
        _gameSocket.startGame(context);
      } else {
        if (decoded['status'] == 'error') {
          FormState form = joinGameFormKey.currentState;
          var code = decoded['code'];
          var message = decoded['message'];
          if (code == 'invalid_room_id' || code == 'room_full') {
            roomIdError = message;
          } else if (code == 'name_exist') {
            nameError = message;
          } else if (code == 'color_exist') {
            colorError = message;
          }
          form.validate();
        }
      }
    });

    _gameSocket.onSubscribeJoined((status) {
      print('STATUS :- $status');
      if (status == GamePlayStatus.START) {
        _gameSocket.startGame(context);
      }
    });
  }

  bool _validateForm() {
    final FormState form = joinGameFormKey.currentState;
    FocusScope.of(context).requestFocus(new FocusNode());
    roomIdError = '';
    nameError = '';
    colorError = '';
    if (form != null) {
      return form.validate();
    }
    return false;
  }

  void _handleSubmit() {
    final FormState form = joinGameFormKey.currentState;
    if (_validateForm()) {
      form.save();
      _gameSocket.joinGame(roomId, Player(name, color, true));
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
                    key: joinGameFormKey,
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
                            SizedBox(height: 10.0),
                            Container(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0),
                              child: TextFormField(
                                focusNode: _roomIdFocusNode,
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
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: (dynamic value) {
                                  if (value.trim() == '') {
                                    return 'Please enter room code.';
                                  } else if (roomIdError != '') {
                                    return roomIdError;
                                  }
                                  return null;
                                },
                                onSaved: (String value) {
                                  roomId = int.parse(value);
                                },
                                onFieldSubmitted: (_) {
                                  if (name == '') {
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
                            SizedBox(height: 10.0),
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
                                  } else if (nameError != '') {
                                    return nameError;
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
                        SizedBox(height: 30.0),
                        FormField(
                          validator: (_) {
                            if (color == '') {
                              return 'Please select color.';
                            } else if (colorError != '') {
                              return colorError;
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
                            height: 45.0,
                            child: AnimatedButton(
                                child: Text('JOIN',
                                    style: AppTextStyles.buttonText
                                        .copyWith(fontSize: 18.0)),
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
    _gameSocket.onUnsubscribeJoined();
    super.dispose();
  }
}
