// ignore_for_file: unused_element

import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class HistoricRepository {
  HistoricRepository._();
  static final HistoricRepository instance = HistoricRepository._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'historic_db.db'),
      version: 1,
    );
  }

  Future<void> _initRepository() async {
    final db = await database;
  }

  Future<void> insertHistoric(Map<String, dynamic> historicData) async {
    final db = await database;
    await db?.insert('historic', historicData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getHistoric() async {
    final db = await database;
    return await db!.query('historic');
  }

  Future<void> updateHistoric(Map<String, dynamic> historicData) async {
    final db = await database;
    await db?.update('historic', historicData,
        where: 'id = ?', whereArgs: [historicData['id']]);
  }

  Future<void> deleteHistoric(int historicId) async {
    final db = await database;
    await db?.delete('historic', where: 'id = ?', whereArgs: [historicId]);
  }
}
