import 'dart:convert';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

const String URI = "http://192.168.0.103:4545";

class GameSocket {
  SocketIO _socketIO;
  int roomId = -1;

  static final GameSocket _singleton = GameSocket._internal();

  factory GameSocket() => _singleton;

  GameSocket._internal();

  void connect() {
    _socketIO = SocketIOManager().createSocketIO(URI, '/',
        socketStatusCallback: (data) {
      print('socketStatusCallback');
      print(data);
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

  void createGame(dynamic payload) {
    _socketIO.sendMessage('create_game', jsonEncode(payload));
  }

  void joinGame(dynamic payload) {
    _socketIO.sendMessage('join_game', jsonEncode(payload));
  }

  void onSubscribeRespond(Function callback) {
    _socketIO.subscribe('respond', callback);
  }

  void onUnsubscribeRespond() {
    _socketIO.unSubscribe('respond');
  }

  void onSubscribeJoined(Function callback) {
    _socketIO.subscribe('joined', callback);
  }

  void onUnsubscribeJoined() {
    _socketIO.unSubscribe('joined');
  }

  void onSubscribePlayerMove(Function callback) {
    _socketIO.subscribe('on_player_move', callback);
  }

  void onUnsubscribePlayerMove() {
    _socketIO.unSubscribe('on_player_move');
  }

  void disconnect() {
    if (_socketIO != null) {
      SocketIOManager().destroyAllSocket();
    }
  }
}
