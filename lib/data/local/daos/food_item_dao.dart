import '../../models/food_item.dart';
import '../database_helper.dart';
import '../database_interface.dart';

/// FoodItem DAO (Data Access Object)
/// 
/// WHAT is a DAO?
/// - A class that handles all database operations for a specific table
/// - Provides a clean interface for CRUD operations
/// - Separates database logic from business logic
/// 
/// WHY use DAOs?
/// - Keeps repository code clean
/// - Reusable database operations
/// - Easy to test
class FoodItemDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  /// Insert a new food item
  /// 
  /// Parameters:
  /// - foodItem: The food item to save
  /// - userId: The ID of the user who logged this food
  /// 
  /// Returns: The ID of the inserted row (not used for TEXT primary keys)
  Future<void> insert(FoodItem foodItem, String userId) async {
    final db = await _dbHelper.database;
    
    // Convert FoodItem to Map for database insertion
    // timestamp is stored as milliseconds since epoch (INTEGER)
    await db.insert(
      'food_items',
      {
        'id': foodItem.id,
        'user_id': userId,
        'name': foodItem.name,
        'calories': foodItem.calories,
        'protein': foodItem.protein,
        'carbs': foodItem.carbs,
        'fat': foodItem.fat,
        'quantity': foodItem.quantity,
        'image_url': foodItem.imageUrl,
        'timestamp': foodItem.timestamp.millisecondsSinceEpoch,
      },
      conflictAlgorithm: 'replace', // Replace if ID exists
    );
  }
  
  /// Get all food items for a specific user on a specific date
  /// 
  /// Parameters:
  /// - userId: The user's ID
  /// - date: The date to query (only year, month, day are used)
  /// 
  /// Returns: List of FoodItems for that date
  Future<List<FoodItem>> getByDate(String userId, DateTime date) async {
    final db = await _dbHelper.database;
    
    // Calculate start and end of the day in milliseconds
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    final startTimestamp = startOfDay.millisecondsSinceEpoch;
    final endTimestamp = endOfDay.millisecondsSinceEpoch;
    
    // Query: Get all food items for this user between start and end of day
    final List<Map<String, dynamic>> maps = await db.query(
      'food_items',
      where: 'user_id = ? AND timestamp >= ? AND timestamp < ?',
      whereArgs: [userId, startTimestamp, endTimestamp],
      orderBy: 'timestamp DESC', // Most recent first
    );
    
    // Convert database maps to FoodItem objects
    return List.generate(maps.length, (i) => _mapToFoodItem(maps[i]));
  }
  
  /// Get all food items for a user in a date range
  /// 
  /// Useful for weekly/monthly reports
  Future<List<FoodItem>> getByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'food_items',
      where: 'user_id = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [userId, startTimestamp, endTimestamp],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) => _mapToFoodItem(maps[i]));
  }
  
  /// Get a single food item by ID
  Future<FoodItem?> getById(String id) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return _mapToFoodItem(maps.first);
  }
  
  /// Update an existing food item
  Future<void> update(FoodItem foodItem) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'food_items',
      {
        'name': foodItem.name,
        'calories': foodItem.calories,
        'protein': foodItem.protein,
        'carbs': foodItem.carbs,
        'fat': foodItem.fat,
        'quantity': foodItem.quantity,
        'image_url': foodItem.imageUrl,
        // Note: timestamp and user_id shouldn't change
      },
      where: 'id = ?',
      whereArgs: [foodItem.id],
    );
  }
  
  /// Delete a food item
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    
    await db.delete(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Delete all food items for a user (useful for account deletion)
  Future<void> deleteAllForUser(String userId) async {
    final db = await _dbHelper.database;
    
    await db.delete(
      'food_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
  
  /// Convert database map to FoodItem object
  /// 
  /// This is a helper method to convert raw database data to our model
  FoodItem _mapToFoodItem(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as String,
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}

