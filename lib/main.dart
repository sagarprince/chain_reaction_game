import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chain_reaction_game/manager.dart';
import 'package:chain_reaction_game/theme.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/utils/keys.dart';
import 'package:chain_reaction_game/blocs/bloc.dart';
import 'package:chain_reaction_game/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppManager.setup();
  GameManager.setup();
  FlareAssets.preload();
  runApp(MyGame());
}

class MyGame extends StatelessWidget {
  MyGame({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_context) => CRBloc(),
      child: MaterialApp(
        title: 'Chain Reaction',
        debugShowCheckedModeBanner: false,
        navigatorKey: Keys.navigatorKey,
        theme: themeData,
        initialRoute: AppRoutes.base,
        onGenerateRoute: (RouteSettings settings) {
          return Routes.builder(settings);
        },
      ),
    );
  }
}
