import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/utils/ui_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/blocs/events.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/blocs/bloc.dart';
import 'package:chain_reaction_game/widgets/animated_button.dart';
import 'package:chain_reaction_game/widgets/color_chooser.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:chain_reaction_game/widgets/positional_back_button.dart';

class MultiPlayerOfflineScreen extends StatefulWidget {
  MultiPlayerOfflineScreen({Key key}) : super(key: key);

  _MultiPlayerOfflineScreenState createState() =>
      _MultiPlayerOfflineScreenState();
}

class _MultiPlayerOfflineScreenState extends State<MultiPlayerOfflineScreen> {
  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _tempPlayers = [];
  int _playersLimit = 2;
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    for (int i = 0; i < _playersLimit; i++) {
      _players.add(_playerToMap((i + 1), 'Player ${i + 1}', '', false));
    }
    _tempPlayers = _players;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!UiUtils.isKeyboardOpened(context)) {
      setPlayerNameEditing();
    }
    super.didChangeDependencies();
  }

  Map<String, dynamic> _playerToMap(
      int id, String name, String color, bool isEditing) {
    return {
      'id': id,
      'name': name,
      'color': color,
      'isHuman': true,
      'isEditing': isEditing
    };
  }

  Player _playerFromMap(Map<String, dynamic> player) {
    return Player(player['name'], player['color'], player['isHuman']);
  }

  List<String> get disabledColors {
    List<String> colors = [];
    _players.forEach((p) {
      String color = p['color'];
      if (color != '') {
        colors.add(color);
      }
    });
    return colors;
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
      _players = [];
      for (int i = 0; i < _playersLimit; i++) {
        int id = (i + 1);
        int index = _tempPlayers.indexWhere((p) => p['id'] == id);
        String name =
            index > -1 ? _tempPlayers[index]['name'] : 'Player ${i + 1}';
        String color = index > -1 ? _tempPlayers[index]['color'] : '';
        _players.add(_playerToMap(id, name, color, false));
      }
      _tempPlayers = _players;
    });
  }

  bool isPlayersColorsSelected() {
    List<String> colors = [];
    _players.forEach((p) {
      if (p['color'] != '') {
        colors.add(p['color']);
      }
    });
    if (colors.length == _playersLimit) {
      return true;
    }
    return false;
  }

  void setPlayerNameEditing([Map<String, dynamic> player]) {
    _players = _players.map((p) {
      p['isEditing'] = false;
      return p;
    }).toList();
    setState(() {
      if (player != null) {
        player['isEditing'] = !player['isEditing'];
      }
    });
  }

  Widget playerWidget(Map<String, dynamic> player) {
    String name = player['name'];
    bool isEditing = player['isEditing'];
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: <Widget>[
          !isEditing
              ? GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 110.0,
                        child: Text('$name',
                            style: AppTextStyles.mediumText,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(width: 10.0),
                      Text('Color', style: AppTextStyles.mediumText)
                    ],
                  ),
                  onTap: () {
                    _controller.text = name;
                    setPlayerNameEditing(player);
                  },
                )
              : Container(
                  padding: EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLength: 24,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.cardinal, width: 2.0),
                            ),
                          ),
                          autofocus: true,
                          cursorColor: AppColors.white,
                          style: AppTextStyles.mediumText,
                          textAlign: TextAlign.center,
                          onChanged: (String value) {
                            if (value.trim() != '') {
                              player['name'] = value;
                            } else {
                              player['name'] = 'Player ${player['id']}';
                            }
                          },
                        ),
                      ),
                      Text(' Color', style: AppTextStyles.mediumText)
                    ],
                  ),
                ),
          SizedBox(height: 10.0),
          ColorChooser(
            activeColor: player['color'],
            disableColors: disabledColors,
            onSelection: (String color) {
              setState(() {
                player['color'] = color;
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Background(
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: !UiUtils.isKeyboardOpened(context)
                      ? (paddingTop + 120)
                      : paddingTop + 50),
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _players.map((p) {
                          return playerWidget(p);
                        }).toList(),
                      ),
                      SizedBox(height: 60.0),
                    ],
                  ),
                ),
              ),
            ),
            !UiUtils.isKeyboardOpened(context)
                ? Positioned(
                    top: (paddingTop + 22),
                    child: Container(
                      width: width,
                      child: Column(
                        children: <Widget>[
                          Text('Number of Players',
                              style: AppTextStyles.regularText),
                          SizedBox(height: 15.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 40.0,
                                height: 40.0,
                                child: AnimatedButton(
                                    child: Icon(Icons.remove,
                                        size: 35.0, color: AppColors.white),
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
                                width: 40.0,
                                height: 40.0,
                                child: AnimatedButton(
                                  child: Icon(Icons.add,
                                      size: 35.0, color: AppColors.white),
                                  onPressed: () {
                                    setPlayersLimit(true);
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
            !UiUtils.isKeyboardOpened(context)
                ? AnimatedPositioned(
                    duration: Duration(milliseconds: 400),
                    bottom: isPlayersColorsSelected() ? 15 : -100,
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
                                child: Text('START',
                                    style: AppTextStyles.buttonText),
                                onPressed: () {
                                  BlocProvider.of<CRBloc>(context).add(
                                      StartGameEvent(
                                          gameMode: GameMode.MultiPlayerOffline,
                                          players: _players
                                              .map((p) => _playerFromMap(p))
                                              .toList()));
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.play_game);
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
    _controller.dispose();
    super.dispose();
  }
}
