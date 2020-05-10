import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/utils/ui_utils.dart';
import 'package:chain_reaction_game/utils/flushbar_helper.dart';
import 'package:chain_reaction_game/game_socket.dart';
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
  GameSocket _gameSocket;
  int _roomId = -1;
  int _playersCount = 2;
  String _myColor = '';

  @override
  void initState() {
    super.initState();
    _gameSocket = GameSocket();
    _roomId = _gameSocket.roomId;
    _playersCount = _gameSocket.playersCount;
    _myColor = _gameSocket.myColor;
    _onSubscriptions();
  }

  void _onSubscriptions() {
    _gameSocket.onSubscribeJoined((status) {
      print('STATUS $status');
      setState(() {});
      if (status == GamePlayStatus.START) {
        Future.delayed(Duration(milliseconds: 200), () {
          _gameSocket.startGame(context);
        });
      }
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
    for (int i = 0; i < _playersCount; i++) {
      if (_gameSocket.players.asMap().containsKey(i)) {
        var player = _gameSocket.players[i];
        if (player['color'] != _myColor) {
          _list.add(_playerCard(player['name'], player['color']));
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
    FlushBarHelper.init(context);
    return WillPopScope(
      onWillPop: () {
        return UiUtils.confirmDialog(
            context: context,
            title: 'Leave Game',
            message: 'Do you want to leave game?',
            callback: () {
              if (_gameSocket.isCreatedByMe) {
                _gameSocket.removeGame();
              } else {
                // Todo: Remove Player from List who join game
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
                        _gameSocket.isCreatedByMe
                            ? ShareRoomCode(
                                scaffoldKey: _scaffoldKey,
                                roomId: _roomId,
                              )
                            : SizedBox(),
                        !_gameSocket.isCreatedByMe
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                child: Text(
                                    'Once all players joined you automatically navigated to game board.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.regularText
                                        .copyWith(fontSize: 20.0)),
                              )
                            : SizedBox(),
                        SizedBox(height: 20.0),
                        _playerCard('You', _gameSocket.myColor),
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
    _gameSocket.onUnsubscribeJoined();
    if (!_gameSocket.isGameStarted) {
      _gameSocket.disconnect();
    }
    super.dispose();
  }
}
