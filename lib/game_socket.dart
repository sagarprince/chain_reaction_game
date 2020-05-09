import 'dart:convert';
import 'package:chain_reaction_game/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/blocs/events.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/blocs/bloc.dart';

const String URI = "http://192.168.0.103:4545";

enum GamePlayStatus { START, WAIT, ERROR, EXCEPTION }

class GameSocket {
  SocketIO _socketIO;
  bool isCreatedByMe = false;
  int roomId = -1;
  int playersCount = 2;
  List<dynamic> players = [];
  String myName = '';
  String myColor = '';
  bool isGameStarted = false;

  static final GameSocket _singleton = GameSocket._internal();

  factory GameSocket() => _singleton;

  GameSocket._internal();

  void connect() {
    disconnect();
    _socketIO = SocketIOManager().createSocketIO(URI, '/',
        socketStatusCallback: (data) {
      print('socketStatusCallback');
      print(data);
      if (data == 'connect_error') {
        // Todo: show message connection error...
      }
      if (data == 'reconnect_error') {
        // Todo: show message reconnecting...
        print('RECONNECTION');
      }
    });
    //call init socket
    _socketIO.init();
    //subscribe event
    _socketIO.subscribe('socket_info', (data) {
      print('Game Socket info: ' + data);
    });
    //connect socket
    _socketIO.connect();
  }

  void createGame(int playersCount, Player player) {
    var payload = {'playersCount': playersCount, 'player': player};
    myName = player.name;
    myColor = player.color;
    isCreatedByMe = true;
    _socketIO.sendMessage('create_game', jsonEncode(payload));
  }

  void joinGame(int roomId, Player player) {
    var payload = {'roomId': roomId, 'player': player};
    myName = player.name;
    myColor = player.color;
    _socketIO.sendMessage('join_game', jsonEncode(payload));
  }

  void removeGame() {
    var payload = {'roomId': roomId};
    _socketIO.sendMessage('remove_game', jsonEncode(payload));
  }

  bool isReadyToStartGame(decoded) {
    var players = decoded['players'];
    if (playersCount == players.length) {
      return true;
    }
    return false;
  }

  void startGame(BuildContext context) {
    print('START GAME');
    print(players);
    BlocProvider.of<CRBloc>(context).add(StartGameEvent(
        gameMode: GameMode.MultiPlayerOnline,
        players: players.map((p) => Player.fromJson(p)).toList()));
    Navigator.of(context).pushReplacementNamed(AppRoutes.play_game);
  }

  void onSubscribeRespond(Function callback) {
    _socketIO.subscribe('respond', (data) {
      Map<String, dynamic> response = {'gamePlayStatus': '', 'decoded': null};
      var decoded = jsonDecode(data);
      var status = decoded['status'];

      if (status == 'created' || status == 'joined') {
        roomId = decoded['roomId'];
        playersCount = decoded['playersCount'];
        players = decoded['players'];
        response['gamePlayStatus'] = GamePlayStatus.WAIT;
      }

      if (status == 'joined') {
        if (isReadyToStartGame(decoded)) {
          isGameStarted = true;
          response['gamePlayStatus'] = GamePlayStatus.START;
        }
      } else if (status == 'error') {
        response['gamePlayStatus'] = GamePlayStatus.ERROR;
      } else if (status == 'exception') {
        response['gamePlayStatus'] = GamePlayStatus.EXCEPTION;
      }

      response['decoded'] = decoded;
      callback(response);
    });
  }

  void onUnsubscribeRespond() {
    _socketIO.unSubscribe('respond');
  }

  void onSubscribeJoined(Function callback) {
    _socketIO.subscribe('joined', (data) {
      print('JOINED');
      var decoded = jsonDecode(data);
      players = decoded['players'];
      if (this.isReadyToStartGame(decoded)) {
        isGameStarted = true;
        callback(GamePlayStatus.START);
      } else {
        callback(GamePlayStatus.WAIT);
      }
    });
  }

  void onUnsubscribeJoined() {
    _socketIO.unSubscribe('joined');
  }

  void move(Position pos, String player) {
    var payload = {'roomId': roomId, 'pos': pos, 'player': player};
    _socketIO.sendMessage('move', jsonEncode(payload));
  }

  void onSubscribePlayedMove(Function callback) {
    _socketIO.subscribe('on_played_move', (data) {
      var decoded = jsonDecode(data);
      callback(decoded);
    });
  }

  void onUnsubscribePlayedMove() {
    _socketIO.unSubscribe('on_played_move');
  }

  void disconnect() {
    if (_socketIO != null) {
      isCreatedByMe = false;
      roomId = -1;
      playersCount = 2;
      players = [];
      myName = '';
      myColor = '';
      isGameStarted = false;
      SocketIOManager().destroyAllSocket();
    }
  }
}
