import '../../models/user_data.dart';
import '../database_helper.dart';
import '../database_interface.dart';

/// UserData DAO (Data Access Object)
/// 
/// Handles all database operations for user profile data
class UserDataDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  /// Insert or update user data
  /// 
  /// Uses INSERT OR REPLACE to handle both new and existing users
  Future<void> upsert(String userId, UserData userData) async {
    final db = await _dbHelper.database;
    
    await db.insert(
      'user_data',
      {
        'user_id': userId,
        'weight': userData.weight,
        'height': userData.height,
        'age': userData.age,
        'activity_level': userData.activityLevel,
        'gender': userData.gender,
        'goal': userData.goal,
        'estimated_calories': userData.estimatedCalories,
        'protein_goal': userData.proteinGoal,
        'fat_goal': userData.fatGoal,
        'carbs_goal': userData.carbsGoal,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: 'replace',
    );
  }
  
  /// Get user data for a specific user
  Future<UserData?> getByUserId(String userId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'user_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC', // Get most recent
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return _mapToUserData(maps.first);
  }
  
  /// Update user data
  Future<void> update(String userId, UserData userData) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'user_data',
      {
        'weight': userData.weight,
        'height': userData.height,
        'age': userData.age,
        'activity_level': userData.activityLevel,
        'gender': userData.gender,
        'goal': userData.goal,
        'estimated_calories': userData.estimatedCalories,
        'protein_goal': userData.proteinGoal,
        'fat_goal': userData.fatGoal,
        'carbs_goal': userData.carbsGoal,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
  
  /// Delete user data (useful for account deletion)
  Future<void> delete(String userId) async {
    final db = await _dbHelper.database;
    
    await db.delete(
      'user_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
  
  /// Convert database map to UserData object
  UserData _mapToUserData(Map<String, dynamic> map) {
    return UserData(
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      age: map['age'] as int,
      activityLevel: map['activity_level'] as String,
      gender: map['gender'] as String,
      goal: map['goal'] as String,
      estimatedCalories: map['estimated_calories'] as int,
      proteinGoal: map['protein_goal'] as int,
      fatGoal: map['fat_goal'] as int,
      carbsGoal: map['carbs_goal'] as int,
    );
  }
}

