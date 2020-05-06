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

  @override
  bool get stringify => true;
}
