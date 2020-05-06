import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:chain_reaction_game/models/cell_info.dart';
import 'package:chain_reaction_game/models/position.dart';
import 'package:chain_reaction_game/game/engine/engine.dart';
import 'package:chain_reaction_game/utils/styles.dart';

class Cell extends PositionComponent with Tapable {
  CREngine _engine;
  Rect boxRect;
  Paint _boxPaint;
  Paint _tappedPaint;
  bool _beenTapped = false;
  Position pos;
  dynamic positionData;

  Cell(
      {CREngine engine,
      double x = 0,
      double y = 0,
      double width = 60,
      double height = 60,
      Position pos,
      dynamic positionData}) {
    this._engine = engine;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.pos = pos;
    this.positionData = positionData;

    boxRect = Rect.fromLTWH(this.x, this.y, this.width, this.height);

    _tappedPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..color = const Color(0xFFDDDDDD).withOpacity(0.5);
  }

  @override
  void render(Canvas c) {
    Color playerColor = AppColors.getColorByName(_engine.playerTurn);
    _boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = playerColor;
    c.drawRect(boxRect, _beenTapped ? _tappedPaint : _boxPaint);
  }

  @override
  void update(double t) {}

  @override
  void onTapUp(TapUpDetails details) {
    int orbs = positionData[0];
    CellInfo cellInfo = positionData[1];
    if (orbs <= 3 &&
        (cellInfo.player == _engine.playerTurn || cellInfo.player == '') &&
        !_engine.isChainReaction &&
        _beenTapped) {
      this._engine.humanMove(pos, _engine.playerTurn);
    }
    _beenTapped = false;
  }

  @override
  void onTapDown(TapDownDetails details) {
    _beenTapped = true;
  }

  @override
  void onTapCancel() {
    _beenTapped = false;
  }
}
