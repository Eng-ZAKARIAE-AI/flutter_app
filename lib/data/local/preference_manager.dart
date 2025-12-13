import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import '../models/food_item.dart';

class PreferenceManager {
  static const String _userDataKey = 'userData';

  final SharedPreferences prefs;

  PreferenceManager(this.prefs);

  Future<void> saveUserData(UserData userData) async {
    final userDataJson = jsonEncode(userData.toJson());
    await prefs.setString(_userDataKey, userDataJson);
  }

  UserData? getUserData() {
    final userDataJson = prefs.getString(_userDataKey);
    if (userDataJson != null) {
      final Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
      return UserData.fromJson(userDataMap);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await prefs.remove(_userDataKey);
  }

  Future<void> saveFoodLog(List<FoodItem> foodLog) async {
    final foodLogJson = jsonEncode(foodLog.map((item) => item.toJson()).toList());
    await prefs.setString('foodLog', foodLogJson);
  }

  List<FoodItem>? getFoodLog() {
    final foodLogJson = prefs.getString('foodLog');
    if (foodLogJson != null) {
      final List<dynamic> foodLogList = jsonDecode(foodLogJson);
      return foodLogList.map((json) => FoodItem.fromJson(json)).toList();
    }
    return null;
  }

}

