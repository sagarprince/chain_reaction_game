/// Cell Info
class CellInfo {
  dynamic player;
  bool isExplode;

  CellInfo({this.player = '', this.isExplode = false});

  CellInfo copyWith({dynamic player, bool isExplode}) {
    return new CellInfo(
        player: player ?? this.player, isExplode: isExplode ?? this.isExplode);
  }

  @override
  String toString() => 'CellInfo{player: $player, isExplode: $isExplode}';
}
