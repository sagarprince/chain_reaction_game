import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chain_reaction_game/blocs/events.dart';
import 'package:chain_reaction_game/blocs/state.dart';

class CRBloc extends Bloc<CREvent, CRState> {
  @override
  CRState get initialState {
    return CRState(gameMode: GameMode.PlayVersusBot, players: []);
  }

  @override
  Stream<CRState> mapEventToState(CREvent event) async* {
    switch (event.runtimeType) {
      case StartGameEvent:
        var args = (event as StartGameEvent);
        yield state.copyWith(
            gameMode: args.gameMode,
            players: args.players,
            isMyTurn: false,
            isChainReaction: false);
        break;
      case SetPlayersEvent:
        var args = (event as SetPlayersEvent);
        yield state.copyWith(players: args.players);
        break;
      case SetMyTurnEvent:
        var args = (event as SetMyTurnEvent);
        yield state.copyWith(isMyTurn: args.isMyTurn);
        break;
      case SetChainReactionEvent:
        var args = (event as SetChainReactionEvent);
        yield state.copyWith(isChainReaction: args.isChainReaction);
        break;
      case SetWinnerEvent:
        var args = (event as SetWinnerEvent);
        yield state.copyWith(
            winner: args.winner, isMyTurn: false, isChainReaction: false);
        break;
    }
  }
}
