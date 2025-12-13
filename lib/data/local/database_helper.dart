// Conditional imports for platform-specific database implementations
// On web: import web implementation
// On mobile: import mobile implementation
import 'database_interface.dart';
import 'database_mobile.dart' if (dart.library.html) 'database_web.dart';

/// Database Helper - Singleton Pattern with Platform Support
/// 
/// WHY Singleton?
/// - Only one database connection should exist
/// - Prevents multiple connections (better performance)
/// - Shared across entire app
/// 
/// HOW it works:
/// 1. Private constructor prevents direct instantiation
/// 2. Static instance variable holds the single instance
/// 3. Uses conditional imports to load platform-specific implementation
/// 
/// PLATFORM SUPPORT:
/// - Mobile (Android/iOS): Uses sqflite (SQLite)
/// - Web: Uses sembast (IndexedDB)
/// 
/// The DatabaseInterface abstraction ensures DAOs work on all platforms
class DatabaseHelper {
  // Private constructor - prevents creating instances directly
  DatabaseHelper._privateConstructor();
  
  // Static instance - the single instance we'll use
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  
  // Database instance (using interface, not concrete type)
  static DatabaseInterface? _database;
  
  /// Get the database instance (creates if doesn't exist)
  /// 
  /// This uses lazy initialization - database is only created when first accessed
  /// Returns DatabaseInterface which works on both mobile and web
  Future<DatabaseInterface> get database async {
    // If database already exists, return it
    if (_database != null) return _database!;
    
    // Otherwise, create it using platform-specific factory
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialize the database
  /// 
  /// This creates the database using platform-specific implementation:
  /// - Mobile: Uses createDatabase() from database_mobile.dart
  /// - Web: Uses createDatabase() from database_web.dart
  /// 
  /// Conditional imports ensure the correct function is called
  Future<DatabaseInterface> _initDatabase() async {
    // Conditional import ensures correct factory function is available
    // On web: database_web.dart's createDatabase is imported
    // On mobile: database_mobile.dart's createDatabase is imported
    return await createDatabase();
  }
  
  /// Close the database connection
  /// 
  /// Call this when app closes (optional, but good practice)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
  
  /// Delete the entire database (useful for testing or reset)
  /// 
  /// WARNING: This deletes ALL data!
  /// 
  /// NOTE: Implementation differs by platform:
  /// - Mobile: Deletes SQLite file
  /// - Web: Clears IndexedDB store
  Future<void> deleteDatabase() async {
    await close();
    _database = null;
    // Platform-specific deletion is handled by the implementation
    // For web, we'd need to clear the IndexedDB store
    // For mobile, we'd delete the SQLite file
    // This is a simplified version - full implementation would be platform-specific
  }
}

// Note: createDatabase() function is imported from:
// - database_mobile.dart on mobile platforms (Android/iOS)
// - database_web.dart on web platforms
// Conditional imports ensure the correct implementation is used

