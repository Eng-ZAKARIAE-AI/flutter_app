/// Web Database Implementation (sembast)
/// 
/// This file is ONLY imported on web platforms.
/// It provides a sembast-based implementation of DatabaseInterface.
/// 
/// Conditional import: This file is imported when on web platform.
/// 
/// NOTE: sembast is a NoSQL database, so we need to simulate SQL operations
/// by storing data in a structured way using sembast stores.

import 'package:sembast_web/sembast_web.dart';
import 'database_interface.dart';

/// Web Database Implementation using sembast
/// 
/// Since sembast is NoSQL, we simulate SQL tables using separate stores.
/// Each table becomes a sembast store, and we implement SQL-like operations.
class WebDatabase implements DatabaseInterface {
  final Database _database;
  final Map<String, StoreRef<String, Map<String, dynamic>>> _stores = {};
  final Map<String, StoreRef<int, Map<String, dynamic>>> _autoIncrementStores = {};
  
  WebDatabase(this._database) {
    // Initialize stores for each table using factory methods
    _stores['users'] = stringMapStoreFactory.store('users');
    _stores['food_items'] = stringMapStoreFactory.store('food_items');
    _autoIncrementStores['user_data'] = intMapStoreFactory.store('user_data');
  }
  
  /// Get or create a store for a table
  StoreRef<String, Map<String, dynamic>> _getStringStore(String table) {
    if (!_stores.containsKey(table)) {
      _stores[table] = stringMapStoreFactory.store(table);
    }
    return _stores[table]!;
  }
  
  StoreRef<int, Map<String, dynamic>>? _getIntStore(String table) {
    if (table == 'user_data' && !_autoIncrementStores.containsKey(table)) {
      _autoIncrementStores[table] = intMapStoreFactory.store(table);
    }
    return _autoIncrementStores[table];
  }
  
  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    // sembast doesn't support SQL, so we handle CREATE TABLE statements
    // by ensuring stores exist (they're created lazily)
    // For other SQL statements, we can't execute them directly
    // This is mainly used for table creation, which we handle in initialization
    if (sql.toUpperCase().contains('CREATE TABLE')) {
      // Store already exists or will be created on first use
      return;
    }
    // For other SQL (like CREATE INDEX), we can't execute in sembast
    // Indexes are handled automatically by sembast's key-based storage
  }
  
  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? conflictAlgorithm,
  }) async {
    try {
      // Handle auto-increment tables (user_data)
      if (table == 'user_data') {
        final store = _getIntStore(table)!;
        int? key;
        
        // Check if we need to generate a new key
        if (!values.containsKey('id') || values['id'] == null) {
          // Get the highest existing key and increment
          final allRecords = await store.find(_database);
          if (allRecords.isNotEmpty) {
            final maxKey = allRecords.map((r) => r.key).reduce((a, b) => a > b ? a : b);
            key = maxKey + 1;
          } else {
            key = 1;
          }
        } else {
          key = values['id'] as int;
        }
        
        // Remove id from values if it exists (sembast handles it as key)
        final data = Map<String, dynamic>.from(values);
        data.remove('id');
        
        // Handle conflict algorithm
        if (conflictAlgorithm == 'replace' || conflictAlgorithm == null) {
          await store.record(key).put(_database, data);
        } else if (conflictAlgorithm == 'ignore') {
          final existing = await store.record(key).get(_database);
          if (existing == null) {
            await store.record(key).put(_database, data);
          }
        }
        
        return key;
      } else {
        // Handle string-keyed tables (users, food_items)
        final store = _getStringStore(table);
        
        // Get the primary key (usually 'id')
        String key;
        if (values.containsKey('id') && values['id'] != null) {
          key = values['id'].toString();
        } else {
          // Generate a key if not provided
          key = DateTime.now().millisecondsSinceEpoch.toString();
        }
        
        // Handle conflict algorithm
        if (conflictAlgorithm == 'replace' || conflictAlgorithm == null) {
          await store.record(key).put(_database, values);
        } else if (conflictAlgorithm == 'ignore') {
          final existing = await store.record(key).get(_database);
          if (existing == null) {
            await store.record(key).put(_database, values);
          }
        }
        
        // Return a numeric ID (sembast doesn't return insert ID, so we use key hash)
        return key.hashCode;
      }
    } catch (e) {
      throw Exception('Failed to insert into $table: $e');
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    try {
      final finder = Finder();
      
      // Handle WHERE clause
      if (where != null && whereArgs != null) {
        // Parse WHERE clause (simple implementation)
        // Format: "column = ? AND column2 = ?"
        final conditions = _parseWhereClause(where, whereArgs);
        if (conditions.isNotEmpty) {
          finder.filter = Filter.custom((record) {
            final data = record.value as Map<String, dynamic>;
            // Add the key as 'id' for auto-increment tables
            if (record.key is int && table == 'user_data') {
              data['id'] = record.key;
            }
            return conditions.every((condition) => condition(data));
          });
        }
      }
      
      // Handle ORDER BY
      if (orderBy != null) {
        final orderParts = orderBy.split(' ');
        final column = orderParts[0];
        final ascending = orderParts.length > 1 && orderParts[1].toUpperCase() == 'ASC';
        
        finder.sortOrders = [
          SortOrder(column, ascending),
        ];
      }
      
      // Handle LIMIT
      if (limit != null) {
        finder.limit = limit;
      }
      
      List<Map<String, dynamic>> results;
      
      // Handle auto-increment tables
      if (table == 'user_data') {
        final store = _getIntStore(table)!;
        final records = await store.find(_database, finder: finder);
        results = records.map((record) {
          final data = Map<String, dynamic>.from(record.value);
          data['id'] = record.key; // Add the key as 'id'
          return data;
        }).toList();
      } else {
        final store = _getStringStore(table);
        final records = await store.find(_database, finder: finder);
        results = records.map((record) => record.value).toList();
      }
      
      return results;
    } catch (e) {
      throw Exception('Failed to query $table: $e');
    }
  }
  
  /// Parse WHERE clause into filter functions
  /// 
  /// Simple parser for common WHERE patterns:
  /// - "column = ?"
  /// - "column >= ? AND column < ?"
  List<bool Function(Map<String, dynamic>)> _parseWhereClause(
    String where,
    List<Object?> whereArgs,
  ) {
    final conditions = <bool Function(Map<String, dynamic>)>[];
    final parts = where.split(' AND ');
    int argIndex = 0;
    
    for (final part in parts) {
      final trimmed = part.trim();
      
      if (trimmed.contains(' = ?')) {
        final column = trimmed.split(' = ?')[0].trim();
        final value = whereArgs[argIndex++];
        conditions.add((data) => data[column] == value);
      } else if (trimmed.contains(' >= ?')) {
        final column = trimmed.split(' >= ?')[0].trim();
        final value = whereArgs[argIndex++];
        conditions.add((data) {
          final dataValue = data[column];
          if (dataValue is num && value is num) {
            return dataValue >= value;
          }
          return false;
        });
      } else if (trimmed.contains(' < ?')) {
        final column = trimmed.split(' < ?')[0].trim();
        final value = whereArgs[argIndex++];
        conditions.add((data) {
          final dataValue = data[column];
          if (dataValue is num && value is num) {
            return dataValue < value;
          }
          return false;
        });
      } else if (trimmed.contains(' <= ?')) {
        final column = trimmed.split(' <= ?')[0].trim();
        final value = whereArgs[argIndex++];
        conditions.add((data) {
          final dataValue = data[column];
          if (dataValue is num && value is num) {
            return dataValue <= value;
          }
          return false;
        });
      }
    }
    
    return conditions;
  }
  
  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      int updatedCount = 0;
      
      if (where != null && whereArgs != null) {
        // Find records matching WHERE clause
        final conditions = _parseWhereClause(where, whereArgs);
        final finder = Finder(
          filter: Filter.custom((record) {
            final data = record.value as Map<String, dynamic>;
            // Add key as 'id' for auto-increment tables
            if (record.key is int && table == 'user_data') {
              data['id'] = record.key;
            }
            return conditions.every((condition) => condition(data));
          }),
        );
        
        if (table == 'user_data') {
          final store = _getIntStore(table)!;
          final records = await store.find(_database, finder: finder);
          
          // Update each matching record
          for (final record in records) {
            final updated = Map<String, dynamic>.from(record.value);
            updated.addAll(values);
            updated.remove('id'); // Remove id as it's the key
            await store.record(record.key).put(_database, updated);
            updatedCount++;
          }
        } else {
          final store = _getStringStore(table);
          final records = await store.find(_database, finder: finder);
          
          // Update each matching record
          for (final record in records) {
            final updated = Map<String, dynamic>.from(record.value);
            updated.addAll(values);
            await store.record(record.key).put(_database, updated);
            updatedCount++;
          }
        }
      } else {
        // Update all records (not typical, but handle it)
        if (table == 'user_data') {
          final store = _getIntStore(table)!;
          final allRecords = await store.find(_database);
          for (final record in allRecords) {
            final updated = Map<String, dynamic>.from(record.value);
            updated.addAll(values);
            updated.remove('id');
            await store.record(record.key).put(_database, updated);
            updatedCount++;
          }
        } else {
          final store = _getStringStore(table);
          final allRecords = await store.find(_database);
          for (final record in allRecords) {
            final updated = Map<String, dynamic>.from(record.value);
            updated.addAll(values);
            await store.record(record.key).put(_database, updated);
            updatedCount++;
          }
        }
      }
      
      return updatedCount;
    } catch (e) {
      throw Exception('Failed to update $table: $e');
    }
  }
  
  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      int deletedCount = 0;
      
      if (where != null && whereArgs != null) {
        // Find records matching WHERE clause
        final conditions = _parseWhereClause(where, whereArgs);
        final finder = Finder(
          filter: Filter.custom((record) {
            final data = record.value as Map<String, dynamic>;
            // Add key as 'id' for auto-increment tables
            if (record.key is int && table == 'user_data') {
              data['id'] = record.key;
            }
            return conditions.every((condition) => condition(data));
          }),
        );
        
        if (table == 'user_data') {
          final store = _getIntStore(table)!;
          final records = await store.find(_database, finder: finder);
          
          // Delete each matching record
          for (final record in records) {
            await store.record(record.key).delete(_database);
            deletedCount++;
          }
        } else {
          final store = _getStringStore(table);
          final records = await store.find(_database, finder: finder);
          
          // Delete each matching record
          for (final record in records) {
            await store.record(record.key).delete(_database);
            deletedCount++;
          }
        }
      } else {
        // Delete all records (not typical, but handle it)
        if (table == 'user_data') {
          final store = _getIntStore(table)!;
          await store.delete(_database);
        } else {
          final store = _getStringStore(table);
          await store.delete(_database);
        }
        deletedCount = -1; // Indicate all deleted
      }
      
      return deletedCount;
    } catch (e) {
      throw Exception('Failed to delete from $table: $e');
    }
  }
  
  @override
  Future<void> close() async {
    await _database.close();
  }
}

/// Factory function to create web database
/// 
/// This is called from database_helper.dart on web platforms
/// Exported as createDatabase for conditional imports
Future<DatabaseInterface> createDatabase() async {
  // For web, we use sembast with IndexedDB backend
  // sembast_web uses IndexedDB which is supported in browsers
  final databaseFactory = databaseFactoryWeb;
  
  // Create database path (for web, this is just a name)
  // IndexedDB will store this in the browser's local storage
  final dbPath = 'calorie_tracker.db';
  final database = await databaseFactory.openDatabase(dbPath);
  
  // Initialize the web database wrapper
  final webDb = WebDatabase(database);
  
  // Note: sembast doesn't need explicit table creation
  // Stores are created on first use when we insert/query data
  // The database is ready to use immediately
  
  return webDb;
}

