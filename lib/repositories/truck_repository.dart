import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';


class TruckRepository {
  TruckRepository._();
  static final TruckRepository instance = TruckRepository._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'truck_db.db'),
      version: 1,
    );
  }

  Future<void> _initRepository() async {
    final db = await database;
    // Realize as operações de inicialização necessárias, se houver
  }

  Future<void> insertTruck(Map<String, dynamic> truckData) async {
    final db = await database;
    await db?.insert('trucks', truckData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTrucks() async {
    final db = await database;
    return await db!.query('trucks');
  }

  Future<void> updateTruck(Map<String, dynamic> truckData) async {
    final db = await database;
    await db?.update('trucks', truckData,
        where: 'id = ?', whereArgs: [truckData['id']]);
  }

  Future<void> deleteTruck(int truckId) async {
    final db = await database;
    await db?.delete('trucks', where: 'id = ?', whereArgs: [truckId]);
}
}
