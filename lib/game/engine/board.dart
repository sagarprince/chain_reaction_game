import 'dart:math';
import 'package:chain_reaction_game/utils/utils.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/models/cell_info.dart';
import 'package:chain_reaction_game/game/engine/bot.dart';

class Board {
  int rows = 0;
  int cols = 0;
  bool isBotEnabled = false;
  Bot bot;

  List<List<dynamic>> _matrix = [];
  List<List<dynamic>> get matrix => _matrix;

  int complexityLimit = 18;

  Board([rows = 9, cols = 6, isBotEnabled = false]) {
    this.rows = rows;
    this.cols = cols;
    if (isBotEnabled) {
      this.bot = Bot(this);
    }
    this._matrix = buildMatrix();
  }

  /// Build Board Matrix
  List<List<dynamic>> buildMatrix() {
    return new List.generate(
        rows, (_) => new List.generate(cols, (_) => [0, CellInfo()]));
  }

  /// Get Critical Mass using [pos]
  int criticalMass(Position pos) {
    int r = rows - 1;
    int c = cols - 1;
    int i = pos.i;
    int j = pos.j;

    // Corner Cells
    if (((i == 0 && j == 0 ||
        i == 0 && j == c ||
        i == r && j == 0 ||
        i == r && j == c))) {
      return 2;
    }

    // Vertical/Horizontal Side Cells
    if (((i > 0 && i < r && (j == 0 || j == c)) ||
        (j > 0 && j < c && (i == 0 || i == r)))) {
      return 3;
    }

    return 4;
  }

  /// Find Neighbours of provided [pos]
  List<dynamic> findNeighbours(Position pos) {
    var sides = [
      [pos.i, pos.j + 1],
      [pos.i, pos.j - 1],
      [pos.i + 1, pos.j],
      [pos.i - 1, pos.j]
    ];
    List<dynamic> neighbours = [];
    sides.forEach((n) {
      if ((n[0] > -1 && n[0] < rows) && (n[1] > -1 && n[1] < cols)) {
        neighbours.add(Position(n[0], n[1]));
      }
    });
    return neighbours;
  }

  /// Set Player Move with [matrix][pos][player]
  List<List<dynamic>> setMove(Position pos, dynamic player) {
    List<List<dynamic>> _matrix = _copy(matrix);
    _matrix[pos.i][pos.j][0]++;
    CellInfo info = _matrix[pos.i][pos.j][1];
    info.player = player;
    _matrix[pos.i][pos.j][1] = info;
    return _matrix;
  }

  Future<Position> botMove(List<List<dynamic>> matrix, String player) async {
    return await bot.play(matrix, player);
  }

  /// Find Unstable Cells
  List<Position> findUnstableCells() {
    List<Position> cells = [];
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;
      Position pos = Position(i, j);
      int orbs = _matrix[i][j][0];
      if (orbs >= criticalMass(pos)) {
        cells.add(pos);
      }
    }
    return cells;
  }

  /// Explode on Unstable Cells
  Future<dynamic> explode(List<dynamic> unstable) async {
    return await Future.forEach(unstable, (pos) async {
      var positionData = _matrix[pos.i][pos.j][1];
      positionData.isExplode = true;
      ExplodeSound.play();
      await new Future.delayed(Duration(
          milliseconds: unstable.length > (complexityLimit - 2) ? 120 : 220));
      _matrix[pos.i][pos.j][0] -= criticalMass(pos);
      List<dynamic> neighbours = findNeighbours(pos);
      neighbours.forEach((nPos) {
        _matrix = setMove(nPos, positionData.player);
      });
      // check for remaining orbs and then apply player
      int orbs = _matrix[pos.i][pos.j][0];
      positionData.player = orbs > 0 ? positionData.player : '';
      positionData.isExplode = false;
    });
  }

  /// Shuffle Unstable Positions List
  List<Position> shuffleUnstableList(positions) {
    var random = new Random();
    // Go through all elements.
    for (var i = positions.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = positions[i];
      positions[i] = positions[n];
      positions[n] = temp;
    }
    return positions;
  }

  /// Set Equivalent Orbs After Got Winner
  setEquivalentOrbs() {
    List<List<dynamic>> _matrix = _copy(matrix);
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;
      if (_matrix[i][j][0] >= criticalMass(Position(i, j))) {
        _matrix[i][j][0] = criticalMass(Position(i, j)) - 1;
      }
    }
    return _matrix;
  }

  /// Get Each Player Scores
  List<int> getScores(List<dynamic> players) {
    List<int> playersScores = new List.generate(players.length, (_) => 0);
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;
      int orbs = _matrix[i][j][0];
      CellInfo info = _matrix[i][j][1];
      if (info.player != '' && orbs > 0) {
        int pIndex = players.indexOf(info.player);
        if (pIndex > -1) {
          playersScores[pIndex]++;
        }
      }
    }
    return playersScores;
  }

  /// Reset Board Matrix
  List<List<dynamic>> reset() {
    List<List<dynamic>> _matrix = _copy(matrix);
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols; // determines i
      int j = k % cols; // determines j
      _matrix[i][j][0] = 0;
      _matrix[i][j][1] = CellInfo();
    }
    return _matrix;
  }

  /// Copy Board Matrix
  List<List<dynamic>> _copy(List<List<dynamic>> matrix) {
    return []..addAll(matrix);
  }
}
