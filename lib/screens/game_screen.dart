import 'package:chain_reaction_game/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chain_reaction_game/blocs/bloc.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/blocs/events.dart';
import 'package:chain_reaction_game/game/cr_game.dart';
import 'package:chain_reaction_game/game/engine/engine.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/utils/keys.dart';
import 'package:chain_reaction_game/utils/ui_utils.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:chain_reaction_game/widgets/volume_button.dart';
import 'package:chain_reaction_game/widgets/players_listing.dart';

class GameScreen extends StatelessWidget {
  GameScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CRBloc, CRState>(
        condition: (prevState, state) {
          return prevState != state;
        },
        builder: (context, state) {
          return Background(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned.fill(
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 50, bottom: 10),
                      child: GameView(
                          bloc: BlocProvider.of<CRBloc>(context), state: state),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: Image.asset(
                                'assets/images/close.png',
                              ),
                              iconSize: 32.0,
                              onPressed: () {
                                if (Navigator.canPop(context) &&
                                    !state.isChainReaction) {
                                  Navigator.maybePop(context);
                                }
                              },
                            ),
                            state.gameMode != GameMode.PlayVersusBot
                                ? IconButton(
                                    icon: Icon(Icons.group,
                                        color: AppColors.white),
                                    iconSize: 34.0,
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (BuildContext context) {
                                            return PlayersListing(
                                                players: state.players);
                                          });
                                    },
                                  )
                                : SizedBox(),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return state.isMyTurn
                                    ? Text('-- Your Turn --',
                                        style: AppTextStyles.regularText
                                            .copyWith(
                                                fontSize:
                                                    constraints.maxWidth > 180
                                                        ? 18.0
                                                        : 16.0))
                                    : SizedBox();
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            VolumeButton(),
                            IconButton(
                              icon: Image.asset(
                                'assets/images/rules.png',
                              ),
                              iconSize: 34.0,
                              onPressed: () {
                                UiUtils.showGameRulesDialog(context);
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class GameView extends StatefulWidget {
  final CRBloc bloc;
  final CRState state;

  GameView({Key key, @required this.bloc, @required this.state})
      : assert(bloc != null),
        assert(state != null),
        super(key: key);

  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  CREngine _engine;
  CRGame _game;

  @override
  void initState() {
    _engine = CREngine(
        state: widget.state,
        onMyTurn: (bool isMyTurn) {
          widget.bloc.add(SetMyTurnEvent(isMyTurn));
        },
        onChainReaction: (bool isChainReaction) {
          widget.bloc.add(SetChainReactionEvent(isChainReaction));
        },
        onPlayerLeaveOnlineGame: (players, playersColors) {
          if (playersColors.length > 1) {
            widget.bloc.add(SetPlayersEvent(players: players));
          } else {
            Keys.navigatorKey.currentState
                .popUntil(ModalRoute.withName(AppRoutes.multi_player_online));
            _engine.server.showToast(
                'Sorry no one is available to play game, so that game is closed.',
                Duration(milliseconds: 4000));
          }
        },
        onPlayerEliminated: () {
          UiUtils.showEliminatedDialog(context, () {
            _onLeaveOnlineGame();
            Keys.navigatorKey.currentState.pushReplacementNamed(AppRoutes.base);
          });
        },
        onWinner: (winner) {
          widget.bloc.add(SetWinnerEvent(winner));
          Keys.navigatorKey.currentState.pushReplacementNamed(AppRoutes.result);
        });
    _game = CRGame(_engine);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return UiUtils.confirmDialog(
              context: context,
              title: 'Leave Game',
              message: 'Do you want to leave game?',
              callback: () {
                _onLeaveOnlineGame();
              });
        },
        child: _game.widget);
  }

  void _onLeaveOnlineGame() {
    if (widget.state.gameMode == GameMode.MultiPlayerOnline) {
      widget.bloc.add(SetMyTurnEvent(false));
      _engine.server.leaveGame(true);
    }
  }

  @override
  void dispose() {
    _engine.destroy();
    super.dispose();
  }
}
