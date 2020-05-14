import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/models/position.dart';

enum GamePlayStatus { INIT, START, WAIT, ERROR, EXCEPTION }

// Game Server Response
class ServerResponse {
  GamePlayStatus gamePlayStatus;
  final String status;
  final String code;
  final String message;
  final int roomId;
  final int playersLimit;
  final List<Player> players;
  final Position pos;
  final String player;

  /// Convenient constructor.
  ServerResponse(
      {this.gamePlayStatus = GamePlayStatus.INIT,
      this.status = '',
      this.code = '',
      this.message = '',
      this.roomId = -1,
      this.playersLimit = 2,
      this.players = const [],
      this.pos,
      this.player});

  factory ServerResponse.fromJson(dynamic json, [String myColor = '']) {
    List<dynamic> _players = json['players'] ?? [];
    List<Player> players = [];
    if (_players.length > 0) {
      _players.forEach((p) {
        players.add(Player.fromJson(p, myColor));
      });
    }
    dynamic _pos = json['pos'] ?? null;
    Position pos;
    if (_pos != null) {
      pos = Position.fromJson(_pos);
    }
    return ServerResponse(
        status: json['status'],
        code: json['code'] ?? '',
        message: json['message'] ?? '',
        roomId: json['roomId'] ?? -1,
        playersLimit: json['playersLimit'] ?? 2,
        players: players,
        pos: pos,
        player: json['player'] ?? '');
  }
}
