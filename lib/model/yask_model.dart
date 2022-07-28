class YaskMatch {
  final String id;
  final DateTime dateTime;
  final String name;
  final int initialScore;
  final List<String> players;

  YaskMatch(
      {required this.id,
      required this.dateTime,
      required this.name,
      required this.initialScore,
      required this.players});

  factory YaskMatch.fromMap(Map<String, dynamic> map) {
    return YaskMatch(
        id: map['id'],
        dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
        name: map['name'],
        initialScore: map['initialScore'],
        players: []);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'name': name,
      'initialScore': initialScore,
    };
  }
}
