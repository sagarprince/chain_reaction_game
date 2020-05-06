import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import "package:flare_flutter/flare_actor.dart";
import "package:flare_flutter/flare_cache_builder.dart";
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chain_reaction_game/blocs/bloc.dart';
import 'package:chain_reaction_game/blocs/events.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/utils/styles.dart';

class WinnerScreen extends StatefulWidget {
  WinnerScreen({Key key}) : super(key: key);

  @override
  _WinnerScreenState createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  String _animationName = "Animations";

  final asset =
      AssetFlare(bundle: rootBundle, name: "assets/flares/fireworks.flr");

  void _resetWinner(BuildContext context) {
    BlocProvider.of<CRBloc>(context).add(SetWinnerEvent(Player('', '', true)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: FlareCacheBuilder(
            [asset],
            builder: (BuildContext context, bool isWarm) {
              return FlareActor.asset(
                asset,
                alignment: Alignment.center,
                fit: BoxFit.fill,
                animation: _animationName,
              );
            },
          ),
        ),
        Positioned.fill(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage('assets/images/winner_trophy.png'),
                width: 220),
            SizedBox(height: 20.0),
            BlocBuilder<CRBloc, CRState>(
              builder: (context, state) {
                return Text(
                  state.winner.name != '' ? state.winner.name : 'Unknown',
                  style: TextStyle(
                      fontSize: 34.0,
                      fontFamily: AppFonts.secondary,
                      color: AppColors.white),
                );
              },
            ),
            SizedBox(height: 5.0),
            Text(
              'WINNER',
              style: TextStyle(
                  fontSize: 32.0,
                  fontFamily: AppFonts.secondary,
                  color: AppColors.white),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(LineAwesomeIcons.home,
                      color: AppColors.white, size: 40.0),
                  onPressed: () {
                    _resetWinner(context);
                    Navigator.of(context).pushReplacementNamed(AppRoutes.base);
                  },
                ),
                SizedBox(width: 20.0),
                IconButton(
                  icon: Icon(LineAwesomeIcons.refresh,
                      color: AppColors.white, size: 40.0),
                  onPressed: () {
                    _resetWinner(context);
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.play_game);
                  },
                )
              ],
            )
          ],
        )),
      ],
    ));
  }
}
