import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class YaskMatch {
  final String id;
  final DateTime startDateTime;
  DateTime endDateTime;
  final String name;
  final int initialScore;
  final List<String> players;
  final List<YaskRound> rounds;

  YaskMatch({
    required this.id,
    required this.startDateTime,
    required this.endDateTime,
    required this.name,
    required this.initialScore,
    required this.players,
    required this.rounds,
  });

  String getFormattedDate(BuildContext context) {
    String startDate =
        DateFormat.yMEd(Localizations.localeOf(context).toString())
            .format(startDateTime);
    String endDate = DateFormat.yMEd(Localizations.localeOf(context).toString())
        .format(endDateTime);

    String startTime = DateFormat.jm(Localizations.localeOf(context).toString())
        .format(startDateTime);
    String endTime = DateFormat.jm(Localizations.localeOf(context).toString())
        .format(endDateTime);

    String ret = "$startDate - $startTime ${AppLocalizations.of(context)!.to} ";
    if (endDate != startDate) {
      ret += "$endDate ";
    }
    ret += endTime;
    return ret;
  }

  Map<String, List<YaskRound>> getPlayerRounds() {
    var ret = <String, List<YaskRound>>{};
    for (String player in players) {
      List<YaskRound> roundsByPlayer =
          rounds.where((element) => element.playerName == player).toList();
      roundsByPlayer.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      ret[player] = roundsByPlayer;
    }
    return ret;
  }

  factory YaskMatch.fromDatabaseMap(Map<String, dynamic> map) {
    return YaskMatch(
      id: map['id'],
      startDateTime: DateTime.fromMillisecondsSinceEpoch(map['startDateTime']),
      endDateTime: DateTime.fromMillisecondsSinceEpoch(map['startDateTime']),
      name: map['name'],
      initialScore: map['initialScore'],
      players: [],
      rounds: [],
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'startDateTime': startDateTime.millisecondsSinceEpoch,
      'name': name,
      'initialScore': initialScore,
    };
  }
}

class YaskRound {
  final DateTime dateTime;
  final String playerName;
  final double score;

  YaskRound({
    required this.dateTime,
    required this.playerName,
    required this.score,
  });
}
