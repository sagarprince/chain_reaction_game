import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

class Background extends PositionComponent {
  Sprite bgSprite;
  Rect bgRect;

  Background() {
    x = y = 0;
    bgSprite = Sprite('background.jpg');
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    bgSprite.renderRect(c, bgRect);
  }

  @override
  void update(double t) {}

  @override
  void resize(Size size) {
    this.width = size.width;
    this.height = size.height;
    bgRect = Rect.fromLTWH(
      0,
      0,
      width,
      height,
    );
  }
}
