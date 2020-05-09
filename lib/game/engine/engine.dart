import 'dart:async';
import 'package:flutter/services.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/game/engine/board.dart';
import 'package:chain_reaction_game/game_socket.dart';

class CREngine {
  CRState _state;
  GameSocket _gameSocket;

  int rows = 9;
  int cols = 6;

  Board _board;
  Board get board => _board;

  List<Player> allPlayers = [];

  List<String> _players = [];

  int _pTurnIndex = 0;

  dynamic _playerTurn = '';
  dynamic get playerTurn => _playerTurn;

  int _totalMoves = 0;

  bool _isChainReaction = false;
  bool get isChainReaction => _isChainReaction;

  String _winner = '';
  String get winner => _winner;

  bool _isBotEnabled = false;

  Function _onWinner;

  CREngine(CRState state, [Function onWinner]) {
    this._state = state;
    _gameSocket = GameSocket();
    this.allPlayers = _state.players;
    _playerTurn = allPlayers[0].color;
    _isBotEnabled = _state.gameMode == GameMode.PlayVersusBot ? true : false;
    this._board = Board(rows, cols, _isBotEnabled);
    this._players = _buildPlayers();
    this._onWinner = onWinner;
    _socketSubscribers();
  }

  List<String> _buildPlayers() {
    List<String> players = [];
    _state.players.forEach((p) {
      players.add(p.color);
    });
    return players;
  }

  void _setNextPlayer() {
    if (_pTurnIndex < _players.length - 1) {
      _pTurnIndex++;
    } else {
      _pTurnIndex = 0;
    }
    _playerTurn = _players[_pTurnIndex];
  }

  void makeMove(Position pos, String player) async {
    _board.setMove(pos, player);
    if (_winner == '') {
      _reactions(pos, player);
    }
    _totalMoves++;
  }

  void _socketSubscribers() {
    if (_state.gameMode == GameMode.MultiPlayerOnline) {
      _gameSocket.onSubscribePlayedMove((data) {
        print(data);
        Position pos = Position.fromJson(data['pos']);
        String player = data['player'];
        makeMove(pos, player);
      });
    }
  }

  void humanMove(Position pos, String player) async {
    if (_isHumanPlayer(player)) {
      if (_state.gameMode == GameMode.MultiPlayerOnline && _isYou(player)) {
        makeMove(pos, player);
        _gameSocket.move(pos, player);
        await HapticFeedback.vibrate(); // vibrate
      }
      if (_state.gameMode == GameMode.PlayVersusBot ||
          _state.gameMode == GameMode.MultiPlayerOffline) {
        makeMove(pos, player);
        await HapticFeedback.vibrate(); // vibrate
      }
    }
  }

  void _botMove() async {
    if (_isBotPlayer(_playerTurn) && _isBotEnabled) {
      Position botPos = await _board.bot.play(_board.matrix, _playerTurn);
      if (botPos != null) {
        makeMove(botPos, _playerTurn);
      }
    }
  }

  void _reactions(Position pos, String player) async {
    Future.microtask(() async {
      while (_winner == '') {
        _isChainReaction = true;
        List<dynamic> unstable = _board.findUnstableCells();

        // Evaluate winner
        _winner = _evaluateWinner();

        // If Winner then Set It
        if (_winner != '') {
          unstable = [];
        }

        // If unstable size gets complex then shuffle unstable list
        if (unstable.length > 0 && unstable.length > _board.complexityLimit) {
          unstable = _board.shuffleUnstableList(unstable);
        }

        // If there are no unstable pos then exit
        if (unstable.length == 0) {
          break;
        }

        // Explode unstable positions
        await _board.explode(unstable);
      }

      _afterReactionsCompleted();
    });
  }

  void _afterReactionsCompleted() {
    _isChainReaction = false;
    if (_winner == '') {
      _setNextPlayer();
      _botMove();
    } else {
      _setWinner();
    }
  }

  String _evaluateWinner() {
    String winner = '';
    if (_totalMoves >= _players.length) {
      List<int> playersScores = _board.getScores(_players);
      int k = 0;
      dynamic player;
      List<dynamic> removedList = [];

      playersScores.forEach((sc) {
        if (sc == 0) {
          removedList.add(_players[k]);
        }
        k++;
      });

      if (removedList.length > 0) {
        player =
            _pTurnIndex <= (_players.length - 1) ? _players[_pTurnIndex] : null;
        removedList.forEach((v) {
          _players.remove(v);
        });
      }

      if (player != null) {
        _pTurnIndex =
            _players.indexOf(player) > -1 ? _players.indexOf(player) : 0;
      }

      if (_players.length == 1) {
        winner = _players[0];
      }
    }
    return winner;
  }

  void _setWinner() async {
    if (_winner != '') {
      _playerTurn = _winner;
      _board.setEquivalentOrbs();
      await Future.delayed(Duration(milliseconds: 600));
      if (_onWinner != null) {
        _onWinner(_getPlayer(_winner));
      }
    }
  }

  bool _isHumanPlayer(String color) {
    int index =
        allPlayers.indexWhere((p) => p.color == color && p.isHuman == true);
    return index > -1;
  }

  bool _isYou(String color) {
    return _gameSocket.myColor == color;
  }

  bool _isBotPlayer(String color) {
    int index =
        allPlayers.indexWhere((p) => p.color == color && p.isHuman == false);
    return index > -1;
  }

  Player _getPlayer(String color) {
    int index = allPlayers.indexWhere((p) => p.color == color);
    return index > -1 ? allPlayers[index] : null;
  }

  void reset() {
    _board.reset();
    _players = _buildPlayers();
    _pTurnIndex = 0;
    _playerTurn = _players[_pTurnIndex];
    _totalMoves = 0;
    _winner = '';
  }

  void _socketUnSubscribers() {
    if (_state.gameMode == GameMode.MultiPlayerOnline) {
      _gameSocket.onUnsubscribePlayedMove();
      _gameSocket.disconnect();
    }
  }

  void destroy() {
    reset();
    _socketUnSubscribers();
    if (_board.bot != null) {
      _board.bot.stopIsolate();
    }
  }
}
