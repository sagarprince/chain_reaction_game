import 'package:chain_reaction_game/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/utils/ui_utils.dart';
import 'package:chain_reaction_game/models/server_response.dart';
import 'package:chain_reaction_game/game/cr_game_server.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:chain_reaction_game/widgets/positional_back_button.dart';
import 'package:chain_reaction_game/widgets/share_room_code.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class MultiPlayerOnlineWaitScreen extends StatefulWidget {
  MultiPlayerOnlineWaitScreen({Key key}) : super(key: key);
  _MultiPlayerOnlineWaitState createState() => _MultiPlayerOnlineWaitState();
}

class _MultiPlayerOnlineWaitState extends State<MultiPlayerOnlineWaitScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  CRGameServer _gameServer;
  int _roomId = -1;
  int _playersLimit = 2;
  String _myColor = '';

  @override
  void initState() {
    super.initState();
    _gameServer = CRGameServer();
    _roomId = _gameServer.roomId;
    _playersLimit = _gameServer.playersLimit;
    _myColor = _gameServer.myColor;
    _onSubscriptions();
  }

  void _onSubscriptions() {
    _gameServer.onSubscribeJoined((status) {
      setState(() {});
      if (status == GamePlayStatus.START) {
        _gameServer.onUnsubscribePlayerLeaveGame();
        Future.delayed(Duration(milliseconds: 200), () {
          _gameServer.startGame(context);
        });
      }
    });

    _gameServer.onSubscribePlayerLeaveGame((_, __) {
      setState(() {});
    });

    _gameServer.onSubscribeGameRemoved(() {
      Navigator.of(context).pushReplacementNamed(AppRoutes.multi_player_online);
      _gameServer.showToast('Game room removed.', Duration(milliseconds: 3000));
    });
  }

  Widget _playerCard(String name, String color, [bool isWait = false]) {
    return Container(
      width: 110.0,
      height: 110.0,
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color:
                color != '' ? AppColors.getColorByName(color) : AppColors.white,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(!isWait ? LineAwesomeIcons.user : LineAwesomeIcons.user_plus,
              color: AppColors.white, size: 40.0),
          Text(name,
              textAlign: TextAlign.center,
              style: AppTextStyles.regularText,
              overflow: TextOverflow.ellipsis)
        ],
      ),
    );
  }

  Widget _playersWaitingList() {
    List<Widget> _list = [];
    for (int i = 0; i < _playersLimit; i++) {
      if (_gameServer.players.asMap().containsKey(i)) {
        var player = _gameServer.players[i];
        if (player.color != _myColor) {
          _list.add(_playerCard(player.name, player.color));
        }
      } else {
        _list.add(_playerCard('Waiting', '', true));
      }
    }
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Center(
          child: Row(
            children: _list.toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return WillPopScope(
      onWillPop: () {
        return UiUtils.confirmDialog(
            context: context,
            title: 'Leave Game',
            message: 'Do you want to leave game?',
            callback: () {
              if (_gameServer.isCreatedByMe) {
                _gameServer.removeGame();
              } else {
                _gameServer.leaveGame(false);
              }
            });
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Background(
          child: Stack(
            children: <Widget>[
              Container(
                child: Center(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                            height: !UiUtils.isKeyboardOpened(context)
                                ? 20
                                : paddingTop + 40),
                        _gameServer.isCreatedByMe
                            ? ShareRoomCode(
                                scaffoldKey: _scaffoldKey,
                                roomId: _roomId,
                              )
                            : SizedBox(),
                        !_gameServer.isCreatedByMe
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                child: Text(
                                    'Waiting for remaining players to join then you navigated to game board.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.regularText
                                        .copyWith(fontSize: 22.0)),
                              )
                            : SizedBox(),
                        SizedBox(height: 50.0),
                        _playerCard('You', _gameServer.myColor),
                        SizedBox(height: 20.0),
                        Text('VS',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.regularText),
                        SizedBox(height: 20.0),
                        _playersWaitingList()
                      ],
                    ),
                  ),
                ),
              ),
              PositionalBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameServer.onUnsubscribeJoined();
    _gameServer.onUnsubscribeGameRemoved();
    if (!_gameServer.isGameStarted) {
      _gameServer.onUnsubscribePlayerLeaveGame();
      _gameServer.disconnect();
    }
    super.dispose();
  }
}
