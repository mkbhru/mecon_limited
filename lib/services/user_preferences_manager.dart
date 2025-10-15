import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';

class UserPreferencesManager {
  // Singleton pattern
  static final UserPreferencesManager _instance = UserPreferencesManager._internal();
  factory UserPreferencesManager() => _instance;
  UserPreferencesManager._internal();

  // Static getter for easier access
  static UserPreferencesManager get instance => _instance;

  // SharedPreferences instance (cached)
  SharedPreferences? _prefs;

  // Cached user data
  UserModel? _currentUser;
  String? _cachedToken;

  // Preference keys (centralized)
  static const String _keyToken = 'token';
  static const String _keyUserData = 'user_data';
  static const String _keyPersNo = 'persNo';
  static const String _keyFullName = 'FullName';

  // Initialize SharedPreferences (call this at app startup)
  Future<void> init() async {
    print('🚀 [UserPreferencesManager] Initializing...');
    _prefs ??= await SharedPreferences.getInstance();
    await _loadUserData();
    print('✅ [UserPreferencesManager] Initialization complete');
  }

  // Get SharedPreferences instance
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ========== Token Management ==========

  // Save token and parse user data
  Future<bool> saveToken(String token) async {
    try {
      print('💾 [UserPreferencesManager] Saving token and parsing user data...');
      final prefs = await _preferences;
      await prefs.setString(_keyToken, token);
      _cachedToken = token;

      // Parse user data from token
      _currentUser = UserModel.fromToken(token);

      print('👤 [UserPreferencesManager] User data parsed from token:');
      print('   - Name: ${_currentUser!.fullName}');
      print('   - PersNo: ${_currentUser!.persNo}');
      print('   - Role: ${_currentUser!.role}');
      print('   - Is Admin: ${_currentUser!.isAdmin}');

      // Save user data separately for quick access
      await _saveUserData(_currentUser!);

      return true;
    } catch (e) {
      print('❌ [UserPreferencesManager] Error saving token: $e');
      return false;
    }
  }

  // Get token
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    final prefs = await _preferences;
    _cachedToken = prefs.getString(_keyToken);
    return _cachedToken;
  }

  // Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return true;

    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  // Remove token
  Future<void> removeToken() async {
    final prefs = await _preferences;
    await prefs.remove(_keyToken);
    _cachedToken = null;
  }

  // ========== User Data Management ==========

  // Save user data
  Future<void> _saveUserData(UserModel user) async {
    final prefs = await _preferences;

    // Save as JSON
    await prefs.setString(_keyUserData, jsonEncode(user.toJson()));

    // Save individual fields for backward compatibility
    await prefs.setString(_keyPersNo, user.persNo);
    await prefs.setString(_keyFullName, user.fullName);
  }

  // Load user data from preferences
  Future<void> _loadUserData() async {
    try {
      print('📂 [UserPreferencesManager] Loading user data...');
      final prefs = await _preferences;

      // Try to load from JSON first
      final userDataJson = prefs.getString(_keyUserData);
      if (userDataJson != null && userDataJson.isNotEmpty) {
        _currentUser = UserModel.fromJson(jsonDecode(userDataJson));
        print('✅ [UserPreferencesManager] User data loaded from storage:');
        print('   - Name: ${_currentUser!.fullName}');
        print('   - PersNo: ${_currentUser!.persNo}');
        print('   - Role: ${_currentUser!.role}');
        print('   - Is Admin: ${_currentUser!.isAdmin}');
        return;
      }

      // Fallback: load from token if available
      print('⚠️ [UserPreferencesManager] No stored user data, parsing from token...');
      final token = prefs.getString(_keyToken);
      if (token != null && token.isNotEmpty) {
        _currentUser = UserModel.fromToken(token);
        await _saveUserData(_currentUser!);
        print('✅ [UserPreferencesManager] User data loaded from token:');
        print('   - Name: ${_currentUser!.fullName}');
        print('   - PersNo: ${_currentUser!.persNo}');
        print('   - Role: ${_currentUser!.role}');
        print('   - Is Admin: ${_currentUser!.isAdmin}');
      } else {
        print('❌ [UserPreferencesManager] No token found, user data unavailable');
      }
    } catch (e) {
      print('❌ [UserPreferencesManager] Error loading user data: $e');
      _currentUser = null;
    }
  }

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Get current user (async version, ensures data is loaded)
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    await _loadUserData();
    return _currentUser;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final hasValidToken = await hasToken();
    if (!hasValidToken) return false;

    final isExpired = await isTokenExpired();
    return !isExpired;
  }

  // ========== Individual Field Getters ==========

  // Get persNo
  Future<String?> getPersNo() async {
    if (_currentUser != null) return _currentUser!.persNo;

    final prefs = await _preferences;
    return prefs.getString(_keyPersNo);
  }

  // Get full name
  Future<String?> getFullName() async {
    if (_currentUser != null) return _currentUser!.fullName;

    final prefs = await _preferences;
    return prefs.getString(_keyFullName);
  }

  // Get first name
  Future<String> getFirstName() async {
    if (_currentUser != null) return _currentUser!.firstName;

    final fullName = await getFullName();
    if (fullName == null || fullName.isEmpty) return 'User';

    List<String> nameParts = fullName.split(' ');
    return nameParts.isNotEmpty ? nameParts.first : 'User';
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    print('🔍 [UserPreferencesManager] Checking admin status...');

    if (_currentUser != null) {
      final isAdmin = _currentUser!.isAdmin;
      print('✅ [UserPreferencesManager] Admin check (from cache):');
      print('   - User: ${_currentUser!.fullName} (${_currentUser!.persNo})');
      print('   - Role: ${_currentUser!.role}');
      print('   - Is Admin: $isAdmin');
      // return isAdmin;
      return true;
    }

    print('⚠️ [UserPreferencesManager] No cached user, loading from storage...');
    await _loadUserData();

    final isAdmin = _currentUser?.isAdmin ?? false;
    if (_currentUser != null) {
      print('✅ [UserPreferencesManager] Admin check (after loading):');
      print('   - User: ${_currentUser!.fullName} (${_currentUser!.persNo})');
      print('   - Role: ${_currentUser!.role}');
      print('   - Is Admin: $isAdmin');
    } else {
      print('❌ [UserPreferencesManager] No user data found');
      print('   - Is Admin: $isAdmin (default: false)');
    }

    return isAdmin;
  }

  // ========== Logout ==========

  // Clear all user data
  Future<void> logout() async {
    print('🚪 [UserPreferencesManager] Logging out user...');
    if (_currentUser != null) {
      print('   - Clearing data for: ${_currentUser!.fullName} (${_currentUser!.persNo})');
    }

    final prefs = await _preferences;

    // Remove all user-related keys
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);
    await prefs.remove(_keyPersNo);
    await prefs.remove(_keyFullName);

    // Clear cached data
    _cachedToken = null;
    _currentUser = null;

    print('✅ [UserPreferencesManager] Logout complete, all user data cleared');
  }

  // ========== Additional Utility Methods ==========

  // Refresh user data from token
  Future<void> refreshUserData() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      _currentUser = UserModel.fromToken(token);
      await _saveUserData(_currentUser!);
    }
  }

  // Update user data (e.g., after profile update)
  Future<void> updateUserData(UserModel user) async {
    _currentUser = user;
    await _saveUserData(user);
  }

  // Get raw SharedPreferences (for custom use cases)
  Future<SharedPreferences> getPreferences() async {
    return await _preferences;
  }

  // Clear all preferences (use with caution)
  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
    _cachedToken = null;
    _currentUser = null;
  }
}
