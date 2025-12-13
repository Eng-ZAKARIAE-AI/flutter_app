import '../models/user_data.dart';
import '../local/daos/user_data_dao.dart';
import '../local/daos/user_dao.dart';
import '../services/auth_service.dart';

/// User Repository
/// 
/// Handles all user-related data operations
class UserRepository {
  final UserDataDao _userDataDao;
  final UserDao _userDao;
  final AuthService _authService;
  
  UserRepository(this._userDataDao, this._userDao, this._authService);
  
  /// Save user profile data
  /// 
  /// Automatically uses the current logged-in user's ID
  Future<void> saveUserData(UserData userData) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      // If no user logged in, create/get default user
      final defaultUserId = await _authService.getOrCreateDefaultUser();
      await _userDataDao.upsert(defaultUserId, userData);
      return;
    }
    await _userDataDao.upsert(userId, userData);
  }
  
  /// Get user profile data
  Future<UserData?> getUserData() async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      final defaultUserId = await _authService.getOrCreateDefaultUser();
      return await _userDataDao.getByUserId(defaultUserId);
    }
    return await _userDataDao.getByUserId(userId);
  }
  
  /// Update user profile data
  Future<void> updateUserData(UserData userData) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      final defaultUserId = await _authService.getOrCreateDefaultUser();
      await _userDataDao.update(defaultUserId, userData);
      return;
    }
    await _userDataDao.update(userId, userData);
  }
  
  /// Create a user account in the database
  Future<void> createUser(String id, String email, {String? name}) async {
    await _userDao.insert(id, email, name: name);
  }
  
  /// Get user account information
  Future<Map<String, dynamic>?> getUser(String id) async {
    return await _userDao.getById(id);
  }
}

