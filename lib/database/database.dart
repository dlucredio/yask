import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yask/model/yask_model.dart';

const matchesTableName = 'matches';
const playersTableName = 'players';
const roundsTableName = 'rounds';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database? _database;
  Future<Database> get database async => _database ?? await _initDB();

  Future<Database> _initDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'yask.db'),
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE $matchesTableName(id TEXT PRIMARY KEY,'
            'startDateTime INT,'
            'name TEXT,'
            'initialScore INT);');
        await db.execute('CREATE TABLE $playersTableName(matchId TEXT,'
            'name TEXT);');
        await db.execute('CREATE TABLE $roundsTableName(matchId TEXT,'
            'playerName TEXT,'
            'score REAL,'
            'dateTime INT);');
      },
      version: 1,
    );
  }

  Future<List<YaskMatch>> getAllYaskMatches() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(matchesTableName);
    List<YaskMatch> matches =
        List.generate(maps.length, (i) => YaskMatch.fromDatabaseMap(maps[i]));
    for (final m in matches) {
      final List<Map<String, dynamic>> matchPlayers = await db.query(
        playersTableName,
        where: 'matchId = ?',
        whereArgs: [m.id],
      );
      for (final mp in matchPlayers) {
        m.players.add(mp['name']);
      }
      List<Map<String, dynamic>> roundMaps = await db.query(
        roundsTableName,
        where: 'matchId = ?',
        whereArgs: [m.id],
      );
      int maxDateTime = 0;
      for (var rm in roundMaps) {
        if (rm['dateTime'] > maxDateTime) {
          maxDateTime = rm['dateTime'];
        }
        m.rounds.add(YaskRound(
          dateTime: DateTime.fromMillisecondsSinceEpoch(rm['dateTime']),
          playerName: rm['playerName'],
          score: rm['score'],
        ));
      }
      m.endDateTime = DateTime.fromMillisecondsSinceEpoch(maxDateTime);
    }
    return matches;
  }

  Future<YaskMatch> getYaskMatch(String matchId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      matchesTableName,
      where: 'id = ?',
      whereArgs: [
        matchId,
      ],
    );
    YaskMatch match = YaskMatch.fromDatabaseMap(maps.first);
    final List<Map<String, dynamic>> matchPlayers = await db
        .query(playersTableName, where: 'matchId = ?', whereArgs: [matchId]);
    for (final mp in matchPlayers) {
      match.players.add(mp['name']);
    }
    List<Map<String, dynamic>> roundMaps = await db.query(
      roundsTableName,
      where: 'matchId = ?',
      whereArgs: [matchId],
    );
    int maxDateTime = 0;
    for (var rm in roundMaps) {
      if (rm['dateTime'] > maxDateTime) {
        maxDateTime = rm['dateTime'];
      }
      match.rounds.add(YaskRound(
        dateTime: DateTime.fromMillisecondsSinceEpoch(rm['dateTime']),
        playerName: rm['playerName'],
        score: rm['score'],
      ));
    }
    match.endDateTime = DateTime.fromMillisecondsSinceEpoch(maxDateTime);
    return match;
  }

  Future<void> insertNewYaskMatch(YaskMatch match) async {
    final db = await database;
    await db.insert(matchesTableName, match.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    for (final mp in match.players) {
      await db.insert(playersTableName, {
        'matchId': match.id,
        'name': mp,
      });
      await db.insert(roundsTableName, {
        'matchId': match.id,
        'playerName': mp,
        'score': match.initialScore,
        'dateTime': match.startDateTime.millisecondsSinceEpoch,
      });
    }
  }

  Future<void> deleteYaskMatch(YaskMatch match) async {
    final db = await database;
    await db.delete(
      matchesTableName,
      where: 'id = ?',
      whereArgs: [match.id],
    );
    await db.delete(
      playersTableName,
      where: 'matchId = ?',
      whereArgs: [match.id],
    );
    await db.delete(
      roundsTableName,
      where: 'matchId = ?',
      whereArgs: [match.id],
    );
  }

  Future<void> insertNewYaskRound(String matchId, YaskRound round) async {
    final db = await database;
    await db.insert(roundsTableName, {
      'matchId': matchId,
      'playerName': round.playerName,
      'score': round.score,
      'dateTime': round.dateTime.millisecondsSinceEpoch,
    });
  }
}
