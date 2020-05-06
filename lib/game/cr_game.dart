import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/position.dart' as FlamePosition;
import 'package:flame/text_config.dart';
import 'package:chain_reaction_game/game/components/background.dart';
import 'package:chain_reaction_game/game/components/cell.dart';
import 'package:chain_reaction_game/game/components/orbs.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/game/engine/engine.dart';

class CRGame extends BaseGame {
  Size screenSize;
  bool _isGridRendering = false;
  CREngine _engine;

  final TextConfig fpsTextConfig =
      const TextConfig(color: const Color(0xFFFFFFFF));

  CRGame(CREngine engine) {
    this._engine = engine;
    add(Background());
  }

  @override
  bool debugMode() => false;

  void buildGrid() {
    if (screenSize != null && !_isGridRendering) {
      _isGridRendering = true;
      int total = _engine.rows * _engine.cols;
      for (int k = 0; k < total; k++) {
        int i = k ~/ _engine.cols;
        int j = k % _engine.cols;

        double width = (screenSize.width / _engine.cols);
        double height = (screenSize.height / _engine.rows);
        double x = j * width;
        double y = i * height;

        Position pos = Position(i, j);
        var positionData = _engine.board.matrix[i][j];

        Cell cell = Cell(
            engine: _engine,
            x: x,
            y: y,
            width: width,
            height: height,
            pos: pos,
            positionData: positionData);

        Orbs orbs = Orbs(
            engine: _engine,
            x: x,
            y: y,
            width: width,
            height: height,
            pos: pos,
            positionData: positionData);

        add(cell);
        add(orbs);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (debugMode()) {
      fpsTextConfig.render(
          canvas,
          fps(120).floorToDouble().toString(),
          FlamePosition.Position(
              screenSize.width / 2 - 20, (screenSize.height - 10)));
    }
  }

  @override
  void resize(Size size) {
    screenSize = size;
    buildGrid();
    super.resize(size);
  }
}
