import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DB {
  // Construtor com acesso privado
  DB._();
  // Criar uma instancia de DB
  static final DB instance = DB._();
  //Instancia do SQLite
  static Database? _database;

  get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'inclinometro.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, versao) async {
    await db.execute(_user);
    await db.execute(_trucks);
    await db.execute(_historic);
    await db.insert('user', {'id': 0});
  }

  String get _user => '''
    CREATE TABLE user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username varchar(50) NOT NULL,
      lastname varchar(50) NOT NULL,
      email varchar(50) NOT NULL,
      password varchar(50) NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  ''';

  String get _trucks => '''
    CREATE TABLE trucks (
      id INTEGER PRIMARY KEY,
      title varchar(50) NOT NULL,
      user_id INTEGER NOT NULL,
      status varchar(50) NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    );
  ''';

  String get _historic => '''
    CREATE TABLE historic (
      truck_id INTEGER PRIMARY KEY AUTOINCREMENT,
      data_operacao INT,
      calibracaolateral REAL;
      calibracaofrontal REAL;
      bloqueiolateral REAL;
      bloqueiolrontal REAL;
    );
  ''';
}