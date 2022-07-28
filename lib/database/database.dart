import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yask/model/yask_model.dart';

const matchesTableName = 'matches';
const playersTableName = 'players';

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
            'dateTime INT,'
            'name TEXT,'
            'initialScore INT);');
        await db.execute('CREATE TABLE $playersTableName(matchId TEXT,'
            'name TEXT);');
      },
      version: 1,
    );
  }

  Future<List<YaskMatch>> getAllYaskMatches() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(matchesTableName);
    List<YaskMatch> matches =
        List.generate(maps.length, (i) => YaskMatch.fromMap(maps[i]));
    for (final m in matches) {
      final List<Map<String, dynamic>> matchPlayers = await db
          .query(playersTableName, where: 'matchId = ?', whereArgs: [m.id]);
      for (final mp in matchPlayers) {
        m.players.add(mp['name']);
      }
    }
    return matches;
  }

  Future<void> insertNewYaskMatch(YaskMatch match) async {
    final db = await database;
    await db.insert(matchesTableName, match.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    for (final mp in match.players) {
      await db.insert(playersTableName, {
        'matchId': match.id,
        'name': mp,
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
  }
}
