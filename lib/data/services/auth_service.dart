import 'package:shared_preferences/shared_preferences.dart';

/// Authentication Service
/// 
/// This is a SIMPLE local authentication service for beginners.
/// It stores user info in SharedPreferences (not secure, but good for learning).
/// 
/// LATER: We'll show how to replace this with Firebase Authentication.
/// 
/// HOW IT WORKS:
/// - When user "logs in", we save their info to SharedPreferences
/// - We check if user is logged in by checking SharedPreferences
/// - User ID is a simple UUID or email-based identifier
class AuthService {
  static const String _userIdKey = 'current_user_id';
  static const String _userEmailKey = 'current_user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  
  final SharedPreferences _prefs;
  
  AuthService(this._prefs);
  
  /// Get the current logged-in user ID
  /// 
  /// Returns null if no user is logged in
  String? getCurrentUserId() {
    return _prefs.getString(_userIdKey);
  }
  
  /// Get the current logged-in user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_userEmailKey);
  }
  
  /// Check if a user is currently logged in
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }
  
  /// Login with email and password (FAKE AUTHENTICATION)
  /// 
  /// This is a SIMPLIFIED version that doesn't actually verify passwords.
  /// For real apps, you'd use Firebase Auth or your own backend.
  /// 
  /// For now, this just:
  /// 1. Creates a user ID from email (or generates one)
  /// 2. Saves login state
  /// 
  /// Parameters:
  /// - email: User's email (used as identifier)
  /// - password: Password (not validated in this simple version)
  /// 
  /// Returns: User ID if successful, null if failed
  Future<String?> login(String email, String password) async {
    // SIMPLE VALIDATION (for learning purposes)
    if (email.isEmpty || password.isEmpty) {
      return null;
    }
    
    // Generate a simple user ID from email
    // In real apps, this would come from your auth provider
    final userId = _generateUserIdFromEmail(email);
    
    // Save login state
    await _prefs.setString(_userIdKey, userId);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setBool(_isLoggedInKey, true);
    
    return userId;
  }
  
  /// Register a new user (FAKE REGISTRATION)
  /// 
  /// In a real app, this would:
  /// 1. Validate email format
  /// 2. Check password strength
  /// 3. Create account in Firebase/backend
  /// 4. Send verification email
  /// 
  /// For now, it just saves the user info locally
  Future<String?> register(String email, String password, {String? name}) async {
    // SIMPLE VALIDATION
    if (email.isEmpty || password.isEmpty || password.length < 6) {
      return null;
    }
    
    // Generate user ID
    final userId = _generateUserIdFromEmail(email);
    
    // Save registration state
    await _prefs.setString(_userIdKey, userId);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setBool(_isLoggedInKey, true);
    
    return userId;
  }
  
  /// Logout the current user
  Future<void> logout() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.setBool(_isLoggedInKey, false);
  }
  
  /// Generate a simple user ID from email
  /// 
  /// In real apps, this would come from Firebase Auth or your backend
  String _generateUserIdFromEmail(String email) {
    // Simple hash-based ID (for learning)
    // In production, use proper UUID or Firebase UID
    return email.replaceAll('@', '_at_').replaceAll('.', '_dot_');
  }
  
  /// Get or create a default user (for when auth is not implemented yet)
  /// 
  /// This allows the app to work without authentication initially
  Future<String> getOrCreateDefaultUser() async {
    String? userId = getCurrentUserId();
    
    if (userId == null) {
      // Create a default user
      userId = 'default_user_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString(_userIdKey, userId);
      await _prefs.setString(_userEmailKey, 'default@example.com');
      await _prefs.setBool(_isLoggedInKey, true);
    }
    
    return userId;
  }
}

