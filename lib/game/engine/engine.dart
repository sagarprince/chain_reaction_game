import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:chain_reaction_game/utils/strings_utils.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/models/server_response.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/game/engine/board.dart';
import 'package:chain_reaction_game/game/cr_game_server.dart';

typedef LeaveGameVoidFunc = void Function(List<Player>, List<dynamic>);

class CREngine {
  CRState _state;
  CRGameServer _gameServer;
  CRGameServer get server => _gameServer;

  int rows = 9;
  int cols = 6;

  Board _board;
  Board get board => _board;

  List<Player> _allPlayers = [];

  List<String> _playersColors = [];

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

  ValueChanged<bool> _onMyTurn;
  ValueChanged<bool> _onChainReaction;
  LeaveGameVoidFunc _onPlayerLeaveOnlineGame;
  VoidCallback _onPlayerEliminated;
  ValueChanged<Player> _onWinner;

  CREngine({
    CRState state,
    ValueChanged<bool> onMyTurn,
    ValueChanged<bool> onChainReaction,
    LeaveGameVoidFunc onPlayerLeaveOnlineGame,
    VoidCallback onPlayerEliminated,
    ValueChanged onWinner,
  }) {
    _state = state;
    _gameServer = CRGameServer();

    this._allPlayers = _state.players;
    _playerTurn = _allPlayers[0].color;

    _isBotEnabled = _state.gameMode == GameMode.PlayVersusBot ? true : false;

    _board = Board(rows, cols, _isBotEnabled);

    _playersColors = _buildPlayersColors();

    _onMyTurn = onMyTurn;
    _onChainReaction = onChainReaction;
    _onPlayerLeaveOnlineGame = onPlayerLeaveOnlineGame;
    _onPlayerEliminated = onPlayerEliminated;
    _onWinner = onWinner;

    _onMyTurn(_playerTurn == _gameServer.myColor ? true : false);

    _socketSubscribers();
  }

  List<String> _buildPlayersColors() {
    List<String> players = [];
    _state.players.forEach((p) {
      players.add(p.color);
    });
    return players;
  }

  void _setNextPlayer() {
    if (_pTurnIndex < _playersColors.length - 1) {
      _pTurnIndex++;
    } else {
      _pTurnIndex = 0;
    }
    _playerTurn = _playersColors[_pTurnIndex];
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
      _gameServer.onSubscribeEliminatedPlayer();
      _gameServer.onSubscribePlayerLeaveGame((players, removed) {
        _onPlayerLeaveGame(players, removed);
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
    if (_totalMoves >= _playersColors.length) {
      List<int> playersScores = _board.getScores(_playersColors);
      int k = 0;
      dynamic player;
      List<dynamic> removedList = [];

      playersScores.forEach((sc) {
        if (sc == 0) {
          removedList.add(_playersColors[k]);
        }
        k++;
      });

      if (removedList.length > 0) {
        player = _pTurnIndex <= (_playersColors.length - 1)
            ? _playersColors[_pTurnIndex]
            : null;
        removedList.forEach((v) {
          _playersColors.remove(v);
        });
      }

      if (player != null) {
        _pTurnIndex = _playersColors.indexOf(player) > -1
            ? _playersColors.indexOf(player)
            : 0;
      }

      if (_playersColors.length == 1) {
        winner = _playersColors[0];
      } else {
        /// Show dialog to player when eliminated in online mode
        if (_state.gameMode == GameMode.MultiPlayerOnline &&
            _playersColors.indexOf(_gameServer.myColor) == -1 &&
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

  void _onPlayerLeaveGame(List<Player> players, Player removed) {
    if (removed != null && _winner == '') {
      int removedIndex = _playersColors.indexOf(removed.color);
      _playersColors.remove(removed.color);

      if (_playersColors.length > 1) {
        if (removedIndex == _pTurnIndex) {
          if (removedIndex > (_playersColors.length - 1)) {
            _pTurnIndex = 0;
          }
        }

        _playerTurn = _playersColors[_pTurnIndex];
        if (_state.gameMode == GameMode.MultiPlayerOnline) {
          _onMyTurn(_playerTurn == _gameServer.myColor ? true : false);
        }

        _board.resetRemovedPlayerOrbs(removed.color);
        _gameServer.showToast('${camelize(removed.name)} leave game.',
            Duration(milliseconds: 2200));
      }

      _onPlayerLeaveOnlineGame(players, _playersColors);
    }
  }

  void reset() {
    _board.reset();
    _playersColors = _buildPlayersColors();
    _pTurnIndex = 0;
    _playerTurn = _playersColors[_pTurnIndex];
    _totalMoves = 0;
    _isYouEliminated = false;
    _winner = '';
  }

  void _disconnectFromServer() {
    if (_state.gameMode == GameMode.MultiPlayerOnline) {
      if (_playersColors.length == 1) {
        _gameServer.removeGame();
      }
      _gameServer.onUnsubscribePlayedMove();
      _gameServer.onUnsubscribeEliminatedPlayer();
      _gameServer.onUnsubscribePlayerLeaveGame();
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
