import '../database_helper.dart';
import '../database_interface.dart';

/// User DAO (Data Access Object)
/// 
/// Handles user account information (not profile data)
class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  /// Create a new user
  /// 
  /// Parameters:
  /// - id: Unique user ID (from authentication)
  /// - email: User's email address
  /// - name: User's display name (optional)
  Future<void> insert(String id, String email, {String? name}) async {
    final db = await _dbHelper.database;
    
    await db.insert(
      'users',
      {
        'id': id,
        'email': email,
        'name': name,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: 'replace',
    );
  }
  
  /// Get user by ID
  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return maps.first;
  }
  
  /// Get user by email
  Future<Map<String, dynamic>?> getByEmail(String email) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return maps.first;
  }
  
  /// Update user information
  Future<void> update(String id, {String? email, String? name}) async {
    final db = await _dbHelper.database;
    
    final Map<String, dynamic> updates = {};
    if (email != null) updates['email'] = email;
    if (name != null) updates['name'] = name;
    
    if (updates.isEmpty) return;
    
    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Delete a user (cascades to user_data and food_items due to FOREIGN KEY)
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

