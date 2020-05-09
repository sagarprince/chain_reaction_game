import 'dart:convert';
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

enum GamePlayStatus { START, WAIT, ERROR }

class GameSocket {
  SocketIO _socketIO;
  int roomId = -1;
  int playersCount = 2;
  List<dynamic> players = [];

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
    _socketIO.sendMessage('create_game', jsonEncode(payload));
  }

  void joinGame(int roomId, Player player) {
    var payload = {'roomId': roomId, 'player': player};
    _socketIO.sendMessage('join_game', jsonEncode(payload));
  }

  bool isReadyToStartGame(decoded) {
    print('IS READY TO START GAME..');
    print(decoded);
    var players = decoded['players'];
    print('Players Count :- $playersCount');
    print('Total Players Joined :- ${players.length}');
    if (playersCount == players.length) {
      return true;
    }
    return false;
  }

  void startGame(BuildContext context) {
    try {
      print('START GAME');
      print(players);
      BlocProvider.of<CRBloc>(context).add(StartGameEvent(
          gameMode: GameMode.MultiPlayerOnline,
          players: players.map((p) => Player.fromJson(p)).toList()));
      Navigator.of(context).pushReplacementNamed(AppRoutes.play_game);
    } catch (e) {
      print('ERROR $e');
    }
  }

  void onSubscribeRespond(Function callback) {
    _socketIO.subscribe('respond', (data) {
      var decoded = jsonDecode(data);
      print('RESPOND $decoded');
      Map<String, dynamic> response = {'gamePlayStatus': '', 'decoded': null};
      if (decoded['status'] == 'created') {
        roomId = decoded['roomId'];
        playersCount = decoded['playersCount'];
        response['gamePlayStatus'] = GamePlayStatus.WAIT;
        response['decoded'] = decoded;
      } else if (decoded['status'] == 'joined') {
        roomId = decoded['roomId'];
        playersCount = decoded['playersCount'];
        players = decoded['players'];
        if (isReadyToStartGame(decoded)) {
          response['gamePlayStatus'] = GamePlayStatus.START;
        } else {
          response['gamePlayStatus'] = GamePlayStatus.WAIT;
        }
      } else {
        response['gamePlayStatus'] = GamePlayStatus.ERROR;
        response['decoded'] = decoded;
      }
      print(response);
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
      SocketIOManager().destroyAllSocket();
    }
  }
}
