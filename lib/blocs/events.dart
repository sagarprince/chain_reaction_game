import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/models/player.dart';

/// Generic Game event.
abstract class CREvent {}

/// Called when user want to start a new game.
class StartGameEvent extends CREvent {
  GameMode gameMode;
  List<Player> players;

  StartGameEvent({this.gameMode = GameMode.PlayVersusBot, this.players})
      : assert(players != null && players.length != 0);
}

/// Called when set players
class SetPlayersEvent extends CREvent {
  List<Player> players;

  SetPlayersEvent({this.players})
      : assert(players != null && players.length != 0);
}

/// Set Winner Event
class SetWinnerEvent extends CREvent {
  Player winner;
  SetWinnerEvent(this.winner);
}
