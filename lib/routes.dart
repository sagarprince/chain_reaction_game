import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/screens/landing_screen.dart';
import 'package:chain_reaction_game/screens/versus_bot_screen.dart';
import 'package:chain_reaction_game/screens/multiplayer_options_screen.dart';
import 'package:chain_reaction_game/screens/multiplayer_offline_screen.dart';
import 'package:chain_reaction_game/screens/multiplayer_online_screen.dart';
import 'package:chain_reaction_game/screens/game_screen.dart';
import 'package:chain_reaction_game/screens/winner_screen.dart';
import 'package:chain_reaction_game/screens/result_screen.dart';

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastLinearToSlowEaseIn,
              ),
            ),
            child: child,
          ),
        );
}

class Routes {
  static builder(settings) {
    switch (settings.name) {
      case AppRoutes.base:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => LandingScreen());
        break;
      case AppRoutes.versus_bot:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => VersusBotScreen());
        break;
      case AppRoutes.multi_player:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => MultiPlayerOptionsScreen());
        break;
      case AppRoutes.multi_player_offline:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => MultiPlayerOfflineScreen());
        break;
      case AppRoutes.multi_player_online:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => MultiPlayerOnlineScreen());
        break;
      case AppRoutes.play_game:
        return ScaleRoute(page: GameScreen());
        break;
      case AppRoutes.winner:
        return ScaleRoute(page: WinnerScreen());
        break;
      case AppRoutes.result:
        return ScaleRoute(page: ResultScreen());
        break;
    }
  }
}
