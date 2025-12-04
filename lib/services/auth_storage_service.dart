import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage authentication data persistence using SharedPreferences.
/// Stores auth tokens and user information to maintain login state across app sessions.
class AuthStorageService {
  // Keys for storing data
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAuthToken = 'auth_token';

  /// Save user authentication data after successful login/signup
  Future<void> saveUserData({
    required String userId,
    required String email,
    String? name,
    String? authToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
    if (name != null) await prefs.setString(_keyUserName, name);
    await prefs.setBool(_keyIsLoggedIn, true);
    
    if (authToken != null) {
      await prefs.setString(_keyAuthToken, authToken);
    }
  }

  /// Retrieve the stored user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Retrieve the stored user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Retrieve the stored user name
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Retrieve the stored auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  /// Check if a user is currently logged in
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Clear all stored authentication data (called on logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyAuthToken);
  }

  /// Get all user data as a map
  Future<Map<String, String?>> getUserData() async {
    return {
      'userId': await getUserId(),
      'email': await getUserEmail(),
      'name': await getUserName(),
      'authToken': await getAuthToken(),
    };
  }
}
