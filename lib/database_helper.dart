import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'yourdatabase.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT NOT NULL,
        father_name TEXT,
        address TEXT,
        aadhar_no TEXT,
        phone_no TEXT,
        group_id TEXT,
        photo TEXT,
        id_front_photo TEXT,
        id_back_photo TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE user_meta (
        id INTEGER PRIMARY KEY,
        current_user_id INTEGER
      )
    ''');
    await db.insert('user_meta', {'id': 1, 'current_user_id': 0});
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    int currentUserId = await getCurrentUserId();
    user['user_id'] = currentUserId + 1;
    await _updateCurrentUserId(user['user_id']);
    return await db.insert('users', user);
  }

  Future<int> getCurrentUserId() async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.query('user_meta', where: 'id = ?', whereArgs: [1]);
    return result.first['current_user_id'];
  }

  Future<void> _updateCurrentUserId(int newUserId) async {
    final db = await database;
    await db.update('user_meta', {'current_user_id': newUserId},
        where: 'id = ?', whereArgs: [1]);
  }
}
