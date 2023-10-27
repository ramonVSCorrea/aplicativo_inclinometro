import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'user_db.db'),
      version: 1,
    );
  }

  Future<void> _initRepository() async {
    final db = await database;
    // Realize as operações de inicialização necessárias, se houver
  }

  Future<void> insertUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db?.insert('user', userData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db!.query('user');
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db?.update('user', userData,
        where: 'id = ?', whereArgs: [userData['id']]);
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db?.delete('user', where: 'id = ?', whereArgs: [userId]);
  }
}