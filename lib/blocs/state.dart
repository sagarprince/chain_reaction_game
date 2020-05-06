import 'package:equatable/equatable.dart';
import 'package:chain_reaction_game/models/player.dart';

/// Representation of the game state.
class CRState extends Equatable {
  /// Convenient constructor.
  const CRState({this.gameMode, this.players, this.winner});

  /// Game Mode
  final GameMode gameMode;

  /// Game Players List
  final List<Player> players;

  /// Game winner
  final Player winner;

  @override
  List<Object> get props => [gameMode, players, winner];

  @override
  bool get stringify => true;

  /// Returns a copy of the current [GameState]
  /// optionally changing some fields.
  CRState copyWith({GameMode gameMode, List<Player> players, Player winner}) {
    return CRState(
        gameMode: gameMode ?? this.gameMode,
        players: players ?? this.players,
        winner: winner ?? this.winner);
  }
}

enum GameMode { PlayVersusBot, MultiPlayerOffline, MultiPlayerOnline }
