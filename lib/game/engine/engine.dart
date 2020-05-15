import 'dart:async';
import 'package:flutter/services.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/models/server_response.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/game/engine/board.dart';
import 'package:chain_reaction_game/game/cr_game_server.dart';

class CREngine {
  CRState _state;
  CRGameServer _gameServer;
  CRGameServer get server => _gameServer;

  int rows = 9;
  int cols = 6;

  Board _board;
  Board get board => _board;

  List<Player> _allPlayers = [];

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

  bool _isYouEliminated = false;

  Function _onWinner;
  Function _onMyTurn;
  Function _onChainReaction;
  Function _onOnlinePlayerRemoved;
  Function _onPlayerEliminated;

  CREngine(CRState state,
      [Function onWinner,
      Function onMyTurn,
      Function onChainReaction,
      Function onOnlinePlayerRemoved,
      Function onPlayerEliminated]) {
    this._state = state;
    _gameServer = CRGameServer();
    this._allPlayers = _state.players;
    _playerTurn = _allPlayers[0].color;
    _isBotEnabled = _state.gameMode == GameMode.PlayVersusBot ? true : false;
    this._board = Board(rows, cols, _isBotEnabled);
    this._players = _buildPlayers();
    this._onWinner = onWinner;
    this._onMyTurn = onMyTurn;
    this._onChainReaction = onChainReaction;
    this._onOnlinePlayerRemoved = onOnlinePlayerRemoved;
    this._onPlayerEliminated = onPlayerEliminated;
    _onMyTurn(_playerTurn == _gameServer.myColor ? true : false);
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
    if (_state.gameMode == GameMode.MultiPlayerOnline) {
      _onMyTurn(_playerTurn == _gameServer.myColor ? true : false);
    }
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
      _gameServer.onSubscribePlayedMove((ServerResponse response) {
        makeMove(response.pos, response.player);
      });
      _gameServer.onSubscribePlayerRemoved((players, removed) {
        onOnlinePlayerLeaveGame(players, removed);
      });
    }
  }

  void humanMove(Position pos, String player) async {
    if (_isHumanPlayer(player)) {
      if (_state.gameMode == GameMode.MultiPlayerOnline && _isYou(player)) {
        makeMove(pos, player);
        _gameServer.move(pos, player);
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
      if (_state.gameMode == GameMode.MultiPlayerOnline) {
        _onChainReaction(true);
      }
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
    if (_state.gameMode == GameMode.MultiPlayerOnline) {
      _onChainReaction(false);
    }
    if (_winner == '') {
      _setNextPlayer();
      _botMove();
      _sendMatrixBoardToServer();
    } else {
      _setWinner();
    }
  }

  void _sendMatrixBoardToServer() {
    if (_state.gameMode == GameMode.MultiPlayerOnline) {
      _gameServer.sendMatrixBoard(_board.matrix);
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
      } else {
        //// Show dialog to player when eliminated in online mode
        if (_state.gameMode == GameMode.MultiPlayerOnline &&
            _players.indexOf(_gameServer.myColor) == -1 &&
            !_isYouEliminated) {
          _isYouEliminated = true;
          _onPlayerEliminated();
        }
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
        _allPlayers.indexWhere((p) => p.color == color && p.isHuman == true);
    return index > -1;
  }

  bool _isYou(String color) {
    return _gameServer.myColor == color;
  }

  bool _isBotPlayer(String color) {
    int index =
        _allPlayers.indexWhere((p) => p.color == color && p.isHuman == false);
    return index > -1;
  }

  Player _getPlayer(String color) {
    int index = _allPlayers.indexWhere((p) => p.color == color);
    return index > -1 ? _allPlayers[index] : null;
  }

  void onOnlinePlayerLeaveGame(List<Player> players, Player removed) {
    if (removed != null && _winner == '') {
      int removedPlayerIndex = _players.indexOf(removed.color);
      _players.remove(removed.color);

      if (_players.length > 1) {
        if (removedPlayerIndex == _pTurnIndex) {
          print(removedPlayerIndex > (_players.length - 1));
          if (removedPlayerIndex > (_players.length - 1)) {
            _pTurnIndex = 0;
          }
        }

        _playerTurn = _players[_pTurnIndex];
        if (_state.gameMode == GameMode.MultiPlayerOnline) {
          _onMyTurn(_playerTurn == _gameServer.myColor ? true : false);
        }

        _board.resetRemovedPlayerOrbs(removed.color);
        _gameServer.showToast(
            '${removed.name} leave game.', Duration(milliseconds: 2200));
      }

      _onOnlinePlayerRemoved(players, _players);
    }
  }

  void reset() {
    _board.reset();
    _players = _buildPlayers();
    _pTurnIndex = 0;
    _playerTurn = _players[_pTurnIndex];
    _totalMoves = 0;
    _winner = '';
  }

  void _disconnectFromServer() {
    if (_state.gameMode == GameMode.MultiPlayerOnline) {
      if (_players.length == 1) {
        _gameServer.removeGame();
      }
      _gameServer.onUnsubscribePlayedMove();
      _gameServer.onUnsubscribePlayerRemoved();
      _gameServer.disconnect();
    }
  }

  void destroy() {
    _disconnectFromServer();
    reset();
    if (_board.bot != null) {
      _board.bot.stopIsolate();
    }
  }
}
