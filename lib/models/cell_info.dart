/// Cell Info
class CellInfo {
  dynamic player;
  bool isExplode;

  CellInfo({this.player = '', this.isExplode = false});

  CellInfo copyWith({dynamic player, bool isExplode}) {
    return new CellInfo(
        player: player ?? this.player, isExplode: isExplode ?? this.isExplode);
  }

  Map<String, dynamic> toJson() => {'player': player, 'isExplode': isExplode};

  factory CellInfo.fromJson(dynamic json) {
    return CellInfo(player: json['player'], isExplode: json['isExplode']);
  }

  @override
  String toString() => 'CellInfo{player: $player, isExplode: $isExplode}';
}
