import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/painting.dart';
import 'package:chain_reaction_game/game/engine/engine.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/models/cell_info.dart';
import 'package:chain_reaction_game/utils/styles.dart';

const ORB_EXPLODE_SPEED = 80.0;

class Orbs extends PositionComponent {
  CREngine _engine;
  Position _pos;
  dynamic _positionData;

  int _rows = 0;
  int _cols = 0;
  double _dx = 0;
  double _dy = 0;
  double _middleDx = 0;
  double _middleDy = 0;
  double _leftDx = 0;
  double _leftDy = 0;
  double _rightDx = 0;
  double _rightDy = 0;
  double _bottomDx = 0;
  double _bottomDy = 0;

  Orbs(
      {CREngine engine,
      double x = 0,
      double y = 0,
      double width = 0,
      double height = 0,
      Position pos,
      dynamic positionData}) {
    this._engine = engine;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this._pos = pos;
    this._positionData = positionData;
    this._dx = (x + width / 2);
    this._dy = (y + height / 2);
    this._rows = _engine.rows;
    this._cols = _engine.cols;
    setOrbsPositions();
  }

  int get orbs => _positionData[0];
  CellInfo get cellInfo => _positionData[1];

  void setOrbsPositions() {
    int i = _pos.i;
    int j = _pos.j;

    if ((i == 0 && j == 0) ||
        (i == (_rows - 1) && j == 0) ||
        (i == (_rows - 1) && j == (_cols - 1))) {
      // Top-Left Corner || Top-Right Corner || Bottom-Right Corner
      this._middleDx = _dx;
      this._middleDy = _dy;
    }

    if (i == 0 && j == 0) {
      // Top-Left Corner
      this._leftDx = _dx + 12;
      this._leftDy = _dy - 12;
    } else if (i == (_rows - 1) && j == 0) {
      // Top-Right Corner
      this._leftDx = _dx - 12;
      this._leftDy = _dy - 12;
    } else if (i == (_rows - 1) && j == (_cols - 1)) {
      // Bottom-Right Corner
      this._leftDx = _dx + 12;
      this._leftDy = _dy - 12;
    } else if ((i > 0 && i < (_rows - 1)) && j == 0) {
      // Left Side
      this._middleDx = _dx + 5;
      this._middleDy = _dy;
      this._leftDx = _dx - 8;
      this._leftDy = _dy - 12;
      this._rightDx = _dx - 8;
      this._rightDy = _dy + 12;
    } else if ((i > 0 && i < (_rows - 1)) && j == (_cols - 1)) {
      // Right Side
      this._middleDx = _dx - 5;
      this._middleDy = _dy;
      this._leftDx = _dx + 8;
      this._leftDy = _dy - 12;
      this._rightDx = _dx + 8;
      this._rightDy = _dy + 12;
    } else if ((i == (_rows - 1)) && (j > 0 && j < (_cols - 1))) {
      // Bottom Side
      this._middleDx = _dx;
      this._middleDy = _dy - 8;
      this._leftDx = _dx - 12;
      this._leftDy = _dy + 6;
      this._rightDx = _dx + 12;
      this._rightDy = _dy + 6;
    } else {
      this._middleDx = _dx;
      this._middleDy = _dy;
      this._leftDx = _dx - 12;
      this._leftDy = _dy - 12;
      this._rightDx = _dx + 12;
      this._rightDy = _dy - 12;
      this._bottomDx = _dx;
      this._bottomDy = _dy + 14;
    }
  }

  void explodeOrbsPositions(double t) {
    int i = _pos.i;
    int j = _pos.j;

    if (i == 0 && j == 0) {
      // Top-Left Corner
      _middleDy = _middleDy + (t * ORB_EXPLODE_SPEED);
      _leftDx = _leftDx + (t * ORB_EXPLODE_SPEED);
    } else if (i == 0 && j == (_cols - 1)) {
      // Top-Right Corner
      _middleDy = _middleDy + (t * ORB_EXPLODE_SPEED);
      _leftDx = _leftDx - (t * ORB_EXPLODE_SPEED);
    } else if (i == (_rows - 1) && j == 0) {
      // Bottom-Left Corner
      _middleDx = _middleDx + (t * ORB_EXPLODE_SPEED);
      _leftDy = _leftDy - (t * ORB_EXPLODE_SPEED);
    } else if (i == (_rows - 1) && j == (_cols - 1)) {
      // Bottom-Right Corner
      _middleDx = _middleDx - (t * ORB_EXPLODE_SPEED);
      _leftDy = _leftDy - (t * ORB_EXPLODE_SPEED);
    } else if ((i == 0) && (j > 0 && j < (_cols - 1))) {
      // Top Side
      _middleDy = _middleDy + (t * ORB_EXPLODE_SPEED);
      _leftDx = _leftDx - (t * ORB_EXPLODE_SPEED);
      _rightDx = _rightDx + (t * ORB_EXPLODE_SPEED);
    } else if ((i > 0 && i < (_rows - 1)) && j == 0) {
      // Left Side
      _middleDx = _middleDx + (t * ORB_EXPLODE_SPEED);
      _leftDy = _leftDy - (t * ORB_EXPLODE_SPEED);
      _rightDy = _rightDy + (t * ORB_EXPLODE_SPEED);
    } else if ((i > 0 && i < (_rows - 1)) && j == (_cols - 1)) {
      // Right Side
      _middleDx = _middleDx - (t * ORB_EXPLODE_SPEED);
      _leftDy = _leftDy - (t * ORB_EXPLODE_SPEED);
      _rightDy = _rightDy + (t * ORB_EXPLODE_SPEED);
    } else {
      _middleDy = _middleDy - (t * ORB_EXPLODE_SPEED);
      _leftDx = _leftDx - (t * ORB_EXPLODE_SPEED);
      _rightDx = _rightDx + (t * ORB_EXPLODE_SPEED);
      _bottomDy = _bottomDy + (t * ORB_EXPLODE_SPEED);
    }
  }

  @override
  void render(Canvas canvas) {
    if (orbs > 0) {
      for (int index = orbs; index > 0; --index) {
        if (index == 1 && _middleDx > 0 && _middleDy > 0) {
          _drawOrb(canvas, _middleDx, _middleDy);
        }
        if (index == 2 && _leftDx > 0 && _leftDx > 0) {
          _drawOrb(canvas, _leftDx, _leftDy);
        }
        if (index == 3 && _rightDx > 0 && _rightDy > 0) {
          _drawOrb(canvas, _rightDx, _rightDy);
        }
        if (index == 4 && _bottomDx > 0 && _bottomDy > 0) {
          _drawOrb(canvas, _bottomDx, _bottomDy);
        }
      }
    }
  }

  @override
  void update(double t) {
    if (orbs > 0 && cellInfo.isExplode) {
      explodeOrbsPositions(t);
    } else {
      setOrbsPositions();
    }
  }

  void _drawOrb(Canvas canvas, double dx, double dy) {
    Rect circleRect = new Rect.fromCircle(
      center: new Offset(dx, dy),
      radius: 12.0,
    );

    Color playerColor = AppColors.getColorByName(cellInfo.player);

    var _gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment(0.5, 1.0),
      colors: [
        playerColor,
        AppColors.darken(playerColor, 0.35)
      ], // whitish to gray
      tileMode: TileMode.clamp,
    );

    // create the Shader from the gradient and the bounding square
    final Paint paint = new Paint()
      ..shader = _gradient.createShader(circleRect);
    canvas.drawCircle(Offset(dx, dy), 12, paint);
  }
}
