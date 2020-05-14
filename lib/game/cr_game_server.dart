import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chain_reaction_game/utils/data_connection_checker.dart';
import 'package:chain_reaction_game/utils/toast_helper.dart';
import 'package:chain_reaction_game/models/server_response.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/blocs/events.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/blocs/bloc.dart';

const String URI = 'http://192.168.0.104:4545';
//const String URI = 'https://chain-reaction-server.herokuapp.com';

class CRGameServer {
  SocketIOManager _manager;
  SocketIO _socketIO;
  bool _isReconnecting = false;
  bool isInitializeConnection = true;
  bool isCreatedByMe = false;
  int roomId = -1;
  int playersLimit = 2;
  List<Player> players = [];
  String myName = '';
  String myColor = '';
  bool isGameStarted = false;

  static final CRGameServer _singleton = CRGameServer._internal();

  factory CRGameServer() => _singleton;

  CRGameServer._internal();

  void connect() async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result) {
      _manager = SocketIOManager();
      _socketIO = await _manager.createInstance(SocketOptions(URI,
          nameSpace: '/', timeout: -1, enableLogging: false));
      _socketIO.connect();
      _onSocketEventListeners();
    } else {
      isInitializeConnection = false;
      _showNoInternetToast();
    }
  }

  StreamSubscription<DataConnectionStatus> onDataConnectionWatcher() {
    return DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          if (!isInitializeConnection && _socketIO == null) {
            connect();
          }
          break;
        case DataConnectionStatus.disconnected:
          break;
      }
    });
  }

  void _onSocketEventListeners() {
    _socketIO.onConnect((data) async {
      print('Connected.');
      isInitializeConnection = false;
      reJoinGame();
      if (_isReconnecting) {
        hideToast();
      }
      _isReconnecting = false;
      showToast('Connected', Duration(milliseconds: 1000));
    });
    // Reconnecting Works for Android not on IOS.
    _socketIO.onReconnecting((_) async {
      print('Reconnecting...');
      if (!_isReconnecting) {
        _showReconnecting();
      }
    });
    // Reconnecting workaround for IOS.
    _socketIO.onReconnect((data) {
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
    hideToast();
    showToast('Reconnecting...', null, true);
  }

  Future<bool> isConnected() async {
    if (_socketIO != null) {
      return await _socketIO.isConnected();
    }
    return Future.value(false);
  }

  void _emit(String evenName, dynamic args) {
    _socketIO.emit(evenName, [args]);
  }

  Future<dynamic> _emitWithAck(String evenName, dynamic args) async {
    return _socketIO.emitWithAck(evenName, [args]);
  }

  ServerResponse _parseServerResponse(data) {
    ServerResponse response;
    try {
      response = ServerResponse.fromJson(data, myColor);
      if (response.status == 'created' || response.status == 'joined') {
        roomId = response.roomId;
        playersLimit = response.playersLimit;
        players = response.players;
        response.gamePlayStatus = GamePlayStatus.WAIT;
      }

      if (response.status == 'joined') {
        if (isReadyToStartGame()) {
          isGameStarted = true;
          response.gamePlayStatus = GamePlayStatus.START;
        }
      } else if (response.status == 'error') {
        response.gamePlayStatus = GamePlayStatus.ERROR;
      } else if (response.status == 'exception') {
        response.gamePlayStatus = GamePlayStatus.EXCEPTION;
      }
    } catch (e) {
      print('Error $e');
    }
    return response;
  }

  Future<ServerResponse> createGame(int playersLimit, Player player) async {
    var payload = {'playersLimit': playersLimit, 'player': player};
    myName = player.name;
    myColor = player.color;
    isCreatedByMe = true;
    var response = await _emitWithAck('create_game', jsonEncode(payload));
    var data = response != null && response is List ? response[0] : null;
    return _parseServerResponse(data);
  }

  Future<ServerResponse> joinGame(int roomId, Player player) async {
    var payload = {'roomId': roomId, 'player': player};
    myName = player.name;
    myColor = player.color;
    var response = await _emitWithAck('join_game', jsonEncode(payload));
    var data = response != null && response is List ? response[0] : null;
    return _parseServerResponse(data);
  }

  void reJoinGame() {
    if (roomId > -1) {
      var payload = {'roomId': roomId};
      _emit('rejoin_game', jsonEncode(payload));
    }
  }

  bool isReadyToStartGame() {
    if (playersLimit == players.length) {
      return true;
    }
    return false;
  }

  void startGame(BuildContext context) {
    print('START GAME');
    BlocProvider.of<CRBloc>(context).add(
        StartGameEvent(gameMode: GameMode.MultiPlayerOnline, players: players));
    Navigator.of(context).pushReplacementNamed(AppRoutes.play_game);
  }

  void onSubscribeJoined(Function callback) {
    _socketIO.on('joined', (data) {
      ServerResponse response = ServerResponse.fromJson(data, myColor);
      players = response.players;
      if (isReadyToStartGame()) {
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

  void sendMatrixBoard(dynamic matrix) {
    var payload = {'roomId': roomId, 'matrix': matrix};
    _emit('copy_matrix_board', jsonEncode(payload));
  }

  void onSubscribePlayedMove(Function callback) {
    _socketIO.on('on_played_move', (data) {
      callback(data);
    });
  }

  void onUnsubscribePlayedMove() {
    _socketIO.off('on_played_move');
  }

  void removeGame() {
    var payload = {'roomId': roomId};
    _emit('remove_game', jsonEncode(payload));
  }

  void _offSocketEventListeners() async {
    print('OFF LISTENERS');
    await _socketIO.off(SocketIO.CONNECT);
    await _socketIO.off(SocketIO.RECONNECT);
    await _socketIO.off(SocketIO.RECONNECTING);
  }

  void _showNoInternetToast() {
    showToast(
        'Please check your internet connection.', Duration(milliseconds: 2000));
  }

  void showToast(String message, Duration duration,
      [bool isDismissible = true]) {
    ToastHelper.showToast(message, duration, isDismissible);
  }

  void hideToast() {
    ToastHelper.hideToast();
  }

  void disconnect() async {
    if (_socketIO != null) {
      isCreatedByMe = false;
      roomId = -1;
      playersLimit = 2;
      players = [];
      myName = '';
      myColor = '';
      isGameStarted = false;
      _isReconnecting = false;
      _offSocketEventListeners();
      await _manager.clearInstance(_socketIO);
      Future.delayed(Duration(milliseconds: 500), () {
        _socketIO = null;
      });
      print('Disconnected...');
    }
  }
}
