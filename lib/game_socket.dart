import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chain_reaction_game/utils/flushbar_helper.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/blocs/events.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/blocs/bloc.dart';

//const String URI = 'http://192.168.0.103:4545';
const String URI = 'https://chain-reaction-server.herokuapp.com';

enum GamePlayStatus { START, WAIT, ERROR, EXCEPTION }

class GameSocket {
  SocketIOManager _ioManager;
  SocketIO _socketIO;
  bool _isReconnecting = false;
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

  void connect() async {
    _ioManager = SocketIOManager();
    _socketIO = await _ioManager.createInstance(
        SocketOptions(URI, nameSpace: '/', timeout: -1, enableLogging: false));
    _socketIO.connect();
    _socketOnEventListeners();
  }

  void _socketOnEventListeners() {
    _socketIO.onConnect((data) async {
      print('Connected.');
      reconnectedGame();
      if (_isReconnecting) {
        hideToast();
      }
      _isReconnecting = false;
      showToast('Connected', Duration(milliseconds: 1000));
    });
    // Reconnecting Works for Android not on IOS.
    _socketIO.onReconnecting((_) async {
      print('RECONNECTING....');
      if (!_isReconnecting) {
        _showReconnecting();
      }
    });
    // Reconnecting workaround for IOS.
    _socketIO.onReconnect((data) {
      print('ReConnected');
      print(data);
      bool isDisconnected = false;
      if (data != null) {
        var err = data.toString().toLowerCase();
        if (err.indexOf('disconnected') > -1 ||
            err.indexOf('error') > -1 ||
            err.indexOf('not connected') > -1) {
          isDisconnected = true;
        }
      }
      if (!_isReconnecting && isDisconnected) {
        _showReconnecting();
      }
    });
  }

  void _showReconnecting() {
    _isReconnecting = true;
    Future.delayed(Duration(milliseconds: 2000), () {
      hideToast();
      Future.delayed(Duration(milliseconds: 300), () {
        showToast('Reconnecting...', null, false);
      });
    });
  }

  Future<bool> isConnected() async {
    return await _socketIO.isConnected();
  }

  void showToast(String message, Duration duration,
      [bool isDismissible = true]) {
    FlushBarHelper.showToast(message, duration, isDismissible);
  }

  void hideToast() {
    FlushBarHelper.hideToast();
  }

  void _emit(String evenName, dynamic args) {
    _socketIO.emit(evenName, [args]);
  }

  Future<dynamic> _emitWithAck(String evenName, dynamic args) async {
    return _socketIO.emitWithAck(evenName, [args]);
  }

  Map<String, dynamic> _convertCreateJoinAck(data) {
    Map<String, dynamic> response = {'gamePlayStatus': '', 'decoded': null};
    try {
      var status = data['status'];

      if (status == 'created' || status == 'joined') {
        roomId = data['roomId'];
        playersCount = data['playersCount'];
        players = data['players'];
        response['gamePlayStatus'] = GamePlayStatus.WAIT;
      }

      if (status == 'joined') {
        if (isReadyToStartGame(data)) {
          isGameStarted = true;
          response['gamePlayStatus'] = GamePlayStatus.START;
        }
      } else if (status == 'error') {
        response['gamePlayStatus'] = GamePlayStatus.ERROR;
      } else if (status == 'exception') {
        response['gamePlayStatus'] = GamePlayStatus.EXCEPTION;
      }

      response['decoded'] = data;
    } catch (e) {
      print('Error $e');
    }
    return response;
  }

  Future<dynamic> createGame(int playersCount, Player player) async {
    var payload = {'playersCount': playersCount, 'player': player};
    myName = player.name;
    myColor = player.color;
    isCreatedByMe = true;
    var response = await _emitWithAck('create_game', jsonEncode(payload));
    var data = response != null && response is List ? response[0] : null;
    return _convertCreateJoinAck(data);
  }

  Future<dynamic> joinGame(int roomId, Player player) async {
    var payload = {'roomId': roomId, 'player': player};
    myName = player.name;
    myColor = player.color;
    var response = await _emitWithAck('join_game', jsonEncode(payload));
    var data = response != null && response is List ? response[0] : null;
    return _convertCreateJoinAck(data);
  }

  void reconnectedGame() {
    var payload = {'roomId': roomId};
    _emit('reconnected_game', jsonEncode(payload));
  }

  void removeGame() {
    var payload = {'roomId': roomId};
    _emit('remove_game', jsonEncode(payload));
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

  void onSubscribeJoined(Function callback) {
    _socketIO.on('joined', (data) {
      players = data['players'];
      if (this.isReadyToStartGame(data)) {
        isGameStarted = true;
        callback(GamePlayStatus.START);
      } else {
        callback(GamePlayStatus.WAIT);
      }
    });
  }

  void onUnsubscribeJoined() {
    _socketIO.off('joined');
  }

  void move(Position pos, String player) {
    var payload = {'roomId': roomId, 'pos': pos, 'player': player};
    _emit('move', jsonEncode(payload));
  }

  void onSubscribePlayedMove(Function callback) {
    _socketIO.on('on_played_move', (data) {
      callback(data);
    });
  }

  void onUnsubscribePlayedMove() {
    _socketIO.off('on_played_move');
  }

  void _socketOffEventListeners() async {
    await _socketIO.off(SocketIO.CONNECT);
    await _socketIO.off(SocketIO.RECONNECT);
    await _socketIO.off(SocketIO.RECONNECTING);
  }

  void disconnect() async {
    if (_socketIO != null) {
      isCreatedByMe = false;
      roomId = -1;
      playersCount = 2;
      players = [];
      myName = '';
      myColor = '';
      isGameStarted = false;
      _isReconnecting = false;
      _socketOffEventListeners();
      await _ioManager.clearInstance(_socketIO);
      print('Disconnected...');
    }
  }
}
