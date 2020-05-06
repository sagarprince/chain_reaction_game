import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/services.dart';
import 'package:flare_flutter/asset_provider.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flare_flutter/flare_cache.dart';

class AppManager {
  static void setup() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarBrightness:
            Brightness.dark // Dark == white status bar -- for IOS.
        ));
  }
}

/// Game manager used to abstract Game Initial Setup.
class GameManager {
  static Future<void> setup() async {
    Flame.audio.disableLog();
    Util flameUtil = Util();
    await flameUtil.setOrientation(DeviceOrientation.portraitUp);
    await Flame.audio.loadAll(<String>[
      'pop.mp3',
    ]);
    await Flame.images.loadAll(<String>['background.jpg']);
  }
}

// Flares
class FlareAssets {
  static List<AssetProvider> assets = [
    AssetFlare(bundle: rootBundle, name: 'assets/flares/character.flr'),
    AssetFlare(bundle: rootBundle, name: 'assets/flares/fireworks.flr'),
  ];
  static Future<void> preload() async {
    for (final asset in assets) {
      await cachedActor(asset);
    }
  }
}
