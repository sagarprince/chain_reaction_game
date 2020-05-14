import 'package:chain_reaction_game/models/player.dart';

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

  /// Convenient constructor.
  ServerResponse(
      {this.gamePlayStatus = GamePlayStatus.INIT,
      this.status = '',
      this.code = '',
      this.message = '',
      this.roomId = -1,
      this.playersLimit = 2,
      this.players = const []});

  factory ServerResponse.fromJson(dynamic json) {
    List<dynamic> _players = json['players'] ?? [];
    List<Player> players = [];
    if (_players.length > 0) {
      _players.forEach((p) {
        players.add(Player.fromJson(p));
      });
    }
    print('players $players');
    return ServerResponse(
        status: json['status'],
        code: json['code'] ?? '',
        message: json['message'] ?? '',
        roomId: json['roomId'] ?? -1,
        playersLimit: json['playersLimit'] ?? 2,
        players: players);
  }
}
