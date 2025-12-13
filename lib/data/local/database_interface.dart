/// Database Interface
/// 
/// This abstract class defines the database operations needed by the app.
/// Different implementations (sqflite for mobile, sembast for web) will
/// implement this interface, allowing the app to work on all platforms.
/// 
/// WHY this approach?
/// - Keeps DAOs unchanged (they use this interface)
/// - Platform-specific implementations handle the differences
/// - Easy to test and maintain
abstract class DatabaseInterface {
  /// Execute a raw SQL query (for table creation, migrations)
  /// 
  /// Used primarily for CREATE TABLE statements and migrations
  Future<void> execute(String sql, [List<Object?>? arguments]);
  
  /// Insert a record into a table
  /// 
  /// Parameters:
  /// - table: Table name
  /// - values: Map of column names to values
  /// - conflictAlgorithm: How to handle conflicts (replace, ignore, etc.)
  /// 
  /// Returns: The ID of the inserted row
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? conflictAlgorithm,
  });
  
  /// Query records from a table
  /// 
  /// Parameters:
  /// - table: Table name
  /// - where: WHERE clause (use ? for parameters)
  /// - whereArgs: Arguments for WHERE clause
  /// - orderBy: ORDER BY clause
  /// - limit: Maximum number of records to return
  /// 
  /// Returns: List of maps representing rows
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  });
  
  /// Update records in a table
  /// 
  /// Parameters:
  /// - table: Table name
  /// - values: Map of column names to new values
  /// - where: WHERE clause
  /// - whereArgs: Arguments for WHERE clause
  /// 
  /// Returns: Number of rows updated
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  });
  
  /// Delete records from a table
  /// 
  /// Parameters:
  /// - table: Table name
  /// - where: WHERE clause
  /// - whereArgs: Arguments for WHERE clause
  /// 
  /// Returns: Number of rows deleted
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  });
  
  /// Close the database connection
  Future<void> close();
}

