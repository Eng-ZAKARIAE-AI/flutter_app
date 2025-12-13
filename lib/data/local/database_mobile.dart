/// Mobile Database Implementation (sqflite)
/// 
/// This file is ONLY imported on mobile platforms (Android/iOS).
/// It provides a sqflite-based implementation of DatabaseInterface.
/// 
/// Conditional import: This file is imported when NOT on web platform.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_interface.dart';

/// Mobile Database Implementation using sqflite
/// 
/// Wraps sqflite Database to implement DatabaseInterface
/// This allows DAOs to work seamlessly on mobile without changes
class MobileDatabase implements DatabaseInterface {
  final Database _database;
  
  MobileDatabase(this._database);
  
  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    await _database.execute(sql, arguments);
  }
  
  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? conflictAlgorithm,
  }) async {
    ConflictAlgorithm algorithm = ConflictAlgorithm.replace;
    if (conflictAlgorithm == 'replace') {
      algorithm = ConflictAlgorithm.replace;
    } else if (conflictAlgorithm == 'ignore') {
      algorithm = ConflictAlgorithm.ignore;
    } else if (conflictAlgorithm == 'fail') {
      algorithm = ConflictAlgorithm.fail;
    }
    
    return await _database.insert(
      table,
      values,
      conflictAlgorithm: algorithm,
    );
  }
  
  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    return await _database.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }
  
  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await _database.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }
  
  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await _database.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }
  
  @override
  Future<void> close() async {
    await _database.close();
  }
}

/// Factory function to create mobile database
/// 
/// This is called from database_helper.dart on mobile platforms
/// Exported as createDatabase for conditional imports
Future<DatabaseInterface> createDatabase() async {
  // Get the database path
  String path = join(await getDatabasesPath(), 'calorie_tracker.db');
  
  // Open/create the database
  final database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Create users table
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          name TEXT,
          created_at INTEGER NOT NULL
        )
      ''');
      
      // Create user_data table
      await db.execute('''
        CREATE TABLE user_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          weight REAL NOT NULL,
          height REAL NOT NULL,
          age INTEGER NOT NULL,
          activity_level TEXT NOT NULL,
          gender TEXT NOT NULL,
          goal TEXT NOT NULL,
          estimated_calories INTEGER NOT NULL,
          protein_goal INTEGER NOT NULL,
          fat_goal INTEGER NOT NULL,
          carbs_goal INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
      
      // Create food_items table
      await db.execute('''
        CREATE TABLE food_items (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          calories REAL NOT NULL,
          protein REAL NOT NULL,
          carbs REAL NOT NULL,
          fat REAL NOT NULL,
          quantity REAL NOT NULL,
          image_url TEXT,
          timestamp INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
      
      // Create indexes
      await db.execute('CREATE INDEX idx_food_items_user_id ON food_items(user_id)');
      await db.execute('CREATE INDEX idx_food_items_timestamp ON food_items(timestamp)');
      await db.execute('CREATE INDEX idx_food_items_date ON food_items(user_id, timestamp)');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      // Handle migrations here
      // For now, no migrations needed
    },
  );
  
  return MobileDatabase(database);
}

