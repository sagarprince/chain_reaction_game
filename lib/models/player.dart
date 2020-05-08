import 'package:equatable/equatable.dart';

// Game Player
class Player extends Equatable {
  /// Convenient constructor.
  Player([this.name = '', this.color = '', this.isHuman = false])
      : assert(isHuman != null);

  /// The Name.
  final String name;

  /// The Color.
  final String color;

  /// The Human.
  final bool isHuman;

  @override
  List<Object> get props => [name, color, isHuman];

  Map<String, dynamic> toJson() =>
      {'name': name, 'color': color, 'isHuman': isHuman};

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(json['name'], json['color'], json['isHuman']);
  }

  @override
  bool get stringify => true;
}
