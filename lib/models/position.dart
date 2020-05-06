import 'package:equatable/equatable.dart';

// Game Cell Position
class Position extends Equatable {
  /// Convenient constructor.
  Position(this.i, this.j)
      : assert(i != null),
        assert(j != null);

  final int i;

  final int j;

  @override
  List<Object> get props => [i, j];

  @override
  bool get stringify => true;
}
