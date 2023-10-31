import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DB {
  DB._();

  static final DB instance = DB._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'inclinometro.db'),
      version: 1,
      onCreate: _onCreate,
    );

    return _database!;
  }

  _onCreate(db, versao) async {
    await db.execute(_user);
    await db.execute(_trucks);
    await db.execute(_historic);
  }

  String get _user => '''
    CREATE TABLE user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      lastname TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  ''';

  String get _trucks => '''
    CREATE TABLE trucks (
      id INTEGER PRIMARY KEY,
      title TEXT NOT NULL,
      user_id INTEGER NOT NULL,
      status TEXT NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  ''';

  String get _historic => '''
    CREATE TABLE historic (
      truck_id INTEGER PRIMARY KEY AUTOINCREMENT,
      data_operacao INT,
      calibracaolateral REAL,
      calibracaofrontal REAL,
      bloqueiolateral REAL,
      bloqueiolrontal REAL
    );
  ''';
}
