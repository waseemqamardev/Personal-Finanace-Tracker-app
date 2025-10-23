import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        token TEXT,
        avatar TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        category TEXT,
        date TEXT,
        type TEXT,
        userId INTEGER
      );
    ''');
  }


  Future<void> clearUserTokens() async {
    final db = await database;
    await db.update('users', {'token': null});
    debugPrint('✅ User tokens cleared');
  }

  // Keep this method but don't use it in logout
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('users');
    await db.delete('transactions');
    debugPrint('✅ Database completely cleared');
  }
}