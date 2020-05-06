import 'dart:collection';
import 'dart:async';
import 'dart:isolate';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/models/cell_info.dart';
import 'package:chain_reaction_game/game/engine/board.dart';

class Bot {
  int _rows = 9;
  int _cols = 6;
  Board _board;
  SendPort _sendPort;
  Isolate _isolate;

  Bot(Board board) {
    this._board = board;
    this._rows = this._board.rows;
    this._cols = this._board.cols;
    _startIsolate();
  }

  _startIsolate() async {
    var receivePort = new ReceivePort();
    _isolate =
        await Isolate.spawn(computeBotMoveOnIsolate, receivePort.sendPort);
    _sendPort = await receivePort.first;
  }

  static computeBotMoveOnIsolate(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    await for (var args in receivePort) {
      Bot bot = args[0];
      List<List<dynamic>> matrix = args[1];
      dynamic player = args[2];
      SendPort callbackPort = args[3];
      List<List<dynamic>> _matrix = bot._clone(matrix);
      List<dynamic> calculatedMove = bot._miniMax(_matrix, player);
      callbackPort.send(calculatedMove);
    }
  }

  Future<Position> play(List<List<dynamic>> matrix, dynamic player) async {
    await Future.delayed(Duration(milliseconds: 600));
    dynamic result = await _communicateWithIsolate(_sendPort, matrix, player);
    print('Return MiniMax $result');
    return result[0];
  }

  // Create your own listening port and send a message to the new isolate
  Future _communicateWithIsolate(
      SendPort sendPort, List<List<dynamic>> matrix, dynamic player) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send([this, matrix, player, receivePort.sendPort]);
    // Receive the return value and return it to the caller
    return receivePort.first;
  }

  List<dynamic> _miniMax(List<List<dynamic>> matrix, player,
      [int depth = 2, int breadth = 2]) {
    List<dynamic> bestMoves = _bestN(matrix, player, breadth);
    Position bestMovePos = bestMoves[0][0];
    int bestMoveScore = bestMoves[1][0];
    depth = bestMoveScore == 10000 ? 1 : depth;
    if (depth == 1) {
      if (bestMoveScore == 10000) {
        print('Exit Here $bestMovePos');
      }
      return [bestMovePos, bestMoveScore];
    }
    List<dynamic> _bestMoves = _bestN(matrix, player, breadth);
    for (int k = 0; k < _bestMoves[0].length; k++) {
      Position _pos = _bestMoves[0][k];
      List<List<dynamic>> bMatrix = _reactions(matrix, _pos, player);
      int score = _miniMax(bMatrix, player, depth - 1)[1];
      if (score > bestMoveScore) {
        bestMoveScore = score;
        bestMovePos = _pos;
      }
    }
    return [bestMovePos, bestMoveScore];
  }

  _bestN(List<List<dynamic>> matrix, dynamic player, [int n = 10]) {
    HashMap<Position, int> conf = HashMap();
    int total = _rows * _cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ _cols;
      int j = k % _cols;
      Position pos = Position(i, j);
      CellInfo info = matrix[pos.i][pos.j][1];
      if (info.player == player || info.player == '') {
        conf[pos] = _score(_reactions(matrix, pos, player), player);
        // Return just the winning position in case you find one
        if (conf[pos] == 10000) {
          return [
            [pos],
            [10000]
          ];
        }
      }
    }

    // Sort by higher score
    Map<Position, int> sorted = Map.fromEntries(
        conf.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    var positions = sorted.keys.toList().take(n).toList();
    var scores = sorted.values.toList().take(n).toList();
    return [positions, scores];
  }

  int _score(List<List<dynamic>> matrix, dynamic player) {
    int sc = 0;
    int myOrbs = 0, enemyOrbs = 0;
    int total = _rows * _cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ _cols;
      int j = k % _cols;

      if (matrix[i][j][1].player == player) {
        myOrbs += matrix[i][j][0];
        bool isNotVulnerable = true;
        Position pos = Position(i, j);
        List<dynamic> neighbours = _board.findNeighbours(pos);
        neighbours.forEach((nPos) {
          CellInfo nInfo = matrix[nPos.i][nPos.j][1];
          if (nInfo.player != player &&
              matrix[nPos.i][nPos.j][0] == (_board.criticalMass(nPos) - 1)) {
            sc -= 5 - _board.criticalMass(pos);
            isNotVulnerable = false;
          }
        });
        if (isNotVulnerable) {
          // The Side Vertical/Horizontal Heuristic
          if (_board.criticalMass(pos) == 3) {
            sc += 2;
          }
          // The Corner Heuristic
          else if (_board.criticalMass(pos) == 2) {
            sc += 3;
          }
          // The Unstability Heuristic
          if (matrix[i][j][0] == (_board.criticalMass(pos) - 1)) {
            sc += 2;
          }
        }
      } else {
        enemyOrbs += matrix[i][j][0];
      }
    }
    // The number of Orbs Heuristic
    sc += myOrbs;
    // You win when the enemy has no orbs
    if (enemyOrbs == 0 && myOrbs > 1)
      return 10000;
    // You loose when you have no orbs
    else if (myOrbs == 0 && enemyOrbs > 1)
      return -10000;
    else {
      // The chain Heuristic
      List<dynamic> chainsList = _chains(matrix, player);
      for (int c = 0; c < chainsList.length; c++) {
        if (c > 1) {
          sc += chainsList[c] * 2;
        }
      }
    }
    return sc;
  }

  List<List<dynamic>> _reactions(
      List<List<dynamic>> matrix, Position pos, String player) {
    List<List<dynamic>> _matrix = _clone(matrix);
    _matrix = _move(_matrix, pos, player);
    int t1 = new DateTime.now().second;
    while (true) {
      List<dynamic> unstable = [];
      int total = _rows * _cols;
      for (int k = 0; k < total; k++) {
        int i = k ~/ _cols;
        int j = k % _cols;
        Position _pos = Position(i, j);
        int orbs = _matrix[i][j][0];
        if (orbs >= _board.criticalMass(_pos)) {
          unstable.add(_pos);
        }
      }
      int t2 = new DateTime.now().second;
      if (t2 - t1 >= 3) {
        // Can't afford to spend more time, strange loop here exit.
        break;
      }

      if (unstable.length == 0) {
        break;
      }

      unstable.forEach((uPos) {
        var positionData = _matrix[uPos.i][uPos.j][1];
        _matrix[uPos.i][uPos.j][0] -= _board.criticalMass(uPos);
        List<dynamic> neighbours = _board.findNeighbours(uPos);
        neighbours.forEach((nPos) {
          _matrix = _move(_matrix, nPos, positionData.player);
        });
        int orbs = _matrix[uPos.i][uPos.j][0];
        positionData.player = orbs > 0 ? positionData.player : '';
      });
    }
    return _matrix;
  }

  List<List<dynamic>> _move(
      List<List<dynamic>> matrix, Position pos, String player) {
    matrix[pos.i][pos.j][0]++;
    CellInfo info = matrix[pos.i][pos.j][1];
    info.player = player;
    return matrix;
  }

  List<dynamic> _chains(List<List<dynamic>> matrix, dynamic player) {
    List<dynamic> lengths = [];
    int total = _rows * _cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ _cols;
      int j = k % _cols;
      Position pos = Position(i, j);
      int orbs = matrix[i][j][0];
      CellInfo info = matrix[pos.i][pos.j][1];
      if (orbs == (_board.criticalMass(pos) - 1) && info.player == player) {
        int l = 0;
        List<dynamic> visitingStack = [];
        visitingStack.add(pos);
        while (visitingStack.length > 0) {
          Position _pos = visitingStack.removeLast();
          matrix[_pos.i][_pos.j][0] = 0;
          l += 1;
          List<dynamic> neighbours = _board.findNeighbours(_pos);
          neighbours.forEach((nPos) {
            int nOrbs = matrix[nPos.i][nPos.j][0];
            CellInfo nInfo = matrix[nPos.i][nPos.j][1];
            if (nOrbs == (_board.criticalMass(pos) - 1) &&
                nInfo.player == player) {
              visitingStack.add(nPos);
            }
          });
        }
        lengths.add(l);
      }
    }
    return lengths;
  }

  List<List<dynamic>> _clone(List<List<dynamic>> matrix) {
    List<List<dynamic>> _matrix = _board.buildMatrix();
    int total = _rows * _cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ _cols;
      int j = k % _cols;
      CellInfo info = matrix[i][j][1];
      _matrix[i][j][0] = matrix[i][j][0];
      _matrix[i][j][1] = info.copyWith();
    }
    return _matrix;
  }

  void stopIsolate() {
    if (_isolate != null) {
      _isolate.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }
}
