import 'package:equatable/equatable.dart';
import 'package:chain_reaction_game/models/player.dart';

/// Representation of the game state.
class CRState extends Equatable {
  /// Convenient constructor.
  const CRState(
      {this.gameMode,
      this.players,
      this.isMyTurn,
      this.isChainReaction,
      this.winner});

  /// Game Mode
  final GameMode gameMode;

  /// Game Players List
  final List<Player> players;

  /// Is My Turn
  final bool isMyTurn;

  /// Is Chain Reaction
  final bool isChainReaction;

  /// Game winner
  final Player winner;

  @override
  List<Object> get props =>
      [gameMode, players, isMyTurn, isChainReaction, winner];

  @override
  bool get stringify => true;

  /// Returns a copy of the current [GameState]
  /// optionally changing some fields.
  CRState copyWith({
    GameMode gameMode,
    List<Player> players,
    bool isMyTurn,
    bool isChainReaction,
    Player winner,
  }) {
    return CRState(
      gameMode: gameMode ?? this.gameMode,
      players: players ?? this.players,
      isMyTurn: isMyTurn ?? this.isMyTurn,
      isChainReaction: isChainReaction ?? this.isChainReaction,
      winner: winner ?? this.winner,
    );
  }
}

enum GameMode { PlayVersusBot, MultiPlayerOffline, MultiPlayerOnline }
