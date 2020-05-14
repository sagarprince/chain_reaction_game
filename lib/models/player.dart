import 'package:equatable/equatable.dart';

// Game Player
class Player extends Equatable {
  /// Convenient constructor.
  Player(
      [this.name = '',
      this.color = '',
      this.isHuman = false,
      this.isYou = false])
      : assert(isHuman != null);

  /// The Name.
  final String name;

  /// The Color.
  final String color;

  /// The Human.
  final bool isHuman;

  /// Is You
  final bool isYou;

  @override
  List<Object> get props => [name, color, isHuman, isYou];

  Map<String, dynamic> toJson() =>
      {'name': name, 'color': color, 'isHuman': isHuman, 'isYou': isYou};

  factory Player.fromJson(dynamic json, [String myColor = '']) {
    String name = json['name'] ?? '';
    String color = json['color'] ?? '';
    bool isHuman = json['isHuman'] ?? true;
    bool isYou = myColor == color ? true : false;
    return Player(name, color, isHuman, isYou);
  }

  @override
  bool get stringify => true;
}
