import 'dart:io';

import 'package:dartz/dartz.dart';
import '../models/food_item.dart';
import '../services/food_service.dart';
import '../local/daos/food_item_dao.dart';
import '../services/auth_service.dart';

/// Food Repository - Refactored to use SQLite
/// 
/// WHAT CHANGED?
/// - Removed SharedPreferences dependency
/// - Now uses FoodItemDao for database operations
/// - All operations require userId (for multi-user support)
/// 
/// WHY?
/// - Better performance (indexed queries)
/// - Proper relationships (food items linked to users)
/// - Scalable (can handle thousands of records)
/// - Supports complex queries (date ranges, filtering)
class FoodRepository {
  final FoodService _foodService;
  final FoodItemDao _foodItemDao;
  final AuthService _authService;
  
  FoodRepository(this._foodService, this._foodItemDao, this._authService);

  /// Get all food items for a specific date
  /// 
  /// Automatically uses the current logged-in user's ID
  Future<List<FoodItem>> getDailyFoodLog(DateTime date) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      // If no user logged in, create/get default user
      final defaultUserId = await _authService.getOrCreateDefaultUser();
      return await _foodItemDao.getByDate(defaultUserId, date);
    }
    return await _foodItemDao.getByDate(userId, date);
  }

  /// Add a new food item
  /// 
  /// Automatically associates it with the current user
  Future<void> addFoodItem(FoodItem item) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      // If no user logged in, create/get default user
      final defaultUserId = await _authService.getOrCreateDefaultUser();
      await _foodItemDao.insert(item, defaultUserId);
      return;
    }
    await _foodItemDao.insert(item, userId);
  }

  /// Detect food from image using AI
  /// 
  /// This still uses the FoodService (no changes needed)
  Future<Either<String, FoodItem>> detectFoodFromImage(File image) async {
    return await _foodService.detectFoodAndCalories(image);
  }

  /// Delete a food item
  Future<void> deleteFoodItem(FoodItem item) async {
    await _foodItemDao.delete(item.id);
  }

  /// Update an existing food item
  Future<void> updateFoodItem(FoodItem item) async {
    await _foodItemDao.update(item);
  }
  
  /// Get food items in a date range (useful for weekly/monthly reports)
  /// 
  /// NEW METHOD: This wasn't possible with SharedPreferences!
  Future<List<FoodItem>> getFoodLogByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      final defaultUserId = await _authService.getOrCreateDefaultUser();
      return await _foodItemDao.getByDateRange(defaultUserId, startDate, endDate);
    }
    return await _foodItemDao.getByDateRange(userId, startDate, endDate);
  }
}