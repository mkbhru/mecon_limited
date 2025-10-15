# UserPreferencesManager - Centralized Data Management Guide

## Overview

The `UserPreferencesManager` provides centralized management of SharedPreferences, JWT tokens, and user data across your application. This eliminates scattered SharedPreferences calls and duplicate JWT decoding.

## Architecture

### Files Created

1. **`lib/models/user_model.dart`** - User data model with JWT parsing
2. **`lib/services/user_preferences_manager.dart`** - Singleton service for data management

### Files Refactored

1. `lib/services/auth_service.dart` - Uses manager for token storage
2. `lib/services/attendance_service.dart` - Removed JWT decoding duplication
3. `lib/services/api_service.dart` - Added token to headers automatically
4. `lib/screens/settings_page.dart` - Uses manager for logout
5. `lib/widgets/greetings.dart` - Uses manager for user name
6. `lib/main.dart` - Initializes manager at startup
7. `lib/screens/attendance_screen.dart` - Uses manager for persNo

## Basic Usage

### 1. Initialization (Already done in main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the preferences manager
  await UserPreferencesManager.instance.init();

  runApp(MyApp());
}
```

### 2. Access User Data

```dart
import 'package:mecon_limited/services/user_preferences_manager.dart';

class MyWidget extends StatelessWidget {
  final _prefsManager = UserPreferencesManager.instance;

  @override
  Widget build(BuildContext context) {
    // Get current user synchronously (cached)
    final user = _prefsManager.currentUser;

    // Or get asynchronously (ensures loaded)
    final userAsync = await _prefsManager.getCurrentUser();

    return Text('Welcome ${user?.firstName ?? "User"}');
  }
}
```

### 3. Get Specific User Information

```dart
// Get personnel number
final persNo = await _prefsManager.getPersNo();

// Get full name
final fullName = await _prefsManager.getFullName();

// Get first name
final firstName = await _prefsManager.getFirstName();

// Check if user is admin
final isAdmin = await _prefsManager.isAdmin();

// Get JWT token
final token = await _prefsManager.getToken();
```

### 4. User Model Properties

```dart
final user = _prefsManager.currentUser;

if (user != null) {
  print(user.persNo);        // Personnel number
  print(user.fullName);      // Full name
  print(user.firstName);     // First name (computed)
  print(user.email);         // Email address
  print(user.role);          // User role
  print(user.department);    // Department
  print(user.designation);   // Designation
  print(user.location);      // Location (optional)
  print(user.phoneNumber);   // Phone number (optional)
  print(user.isAdmin);       // True if admin (computed)
  print(user.isValid);       // True if has persNo (computed)
}
```

### 5. Authentication Flow

The authentication flow is already handled:

```dart
// Login (in auth_service.dart)
final success = await AuthService().login(persNo, password);
// Token is automatically saved and user data is parsed

// Check if logged in
final loggedIn = await _prefsManager.isLoggedIn();

// Logout
await _prefsManager.logout();
```

### 6. Making API Calls with Token

Tokens are automatically included in headers:

```dart
// In api_service.dart - already implemented
static Future<Map<String, String>> _getHeaders() async {
  final token = await _prefsManager.getToken();
  return {
    'Content-Type': 'application/json',
    if (token != null) 'token': token,
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

// Use in API calls
final headers = await _getHeaders();
final response = await http.get(url, headers: headers);
```

## Advanced Usage

### 1. Refresh User Data

```dart
// Refresh user data from token (if token was updated)
await _prefsManager.refreshUserData();
```

### 2. Update User Data

```dart
// Update user data (e.g., after profile update)
final updatedUser = user.copyWith(
  fullName: 'New Name',
  email: 'newemail@example.com',
);
await _prefsManager.updateUserData(updatedUser);
```

### 3. Check Token Expiry

```dart
final isExpired = await _prefsManager.isTokenExpired();
if (isExpired) {
  // Handle expired token - redirect to login
}
```

### 4. Access Raw SharedPreferences (if needed)

```dart
final prefs = await _prefsManager.getPreferences();
// Use prefs for custom keys not managed by UserPreferencesManager
```

## Example: Building Admin Features

```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _prefsManager = UserPreferencesManager.instance;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _prefsManager.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isAdmin
          ? AdminPanel()
          : Text('Access Denied'),
    );
  }
}
```

## Example: Displaying User Info

```dart
class UserProfileWidget extends StatelessWidget {
  final _prefsManager = UserPreferencesManager.instance;

  @override
  Widget build(BuildContext context) {
    final user = _prefsManager.currentUser;

    return Column(
      children: [
        Text('Name: ${user?.fullName ?? "N/A"}'),
        Text('Pers No: ${user?.persNo ?? "N/A"}'),
        Text('Department: ${user?.department ?? "N/A"}'),
        Text('Role: ${user?.role ?? "N/A"}'),
        if (user?.isAdmin ?? false)
          Chip(label: Text('ADMIN')),
      ],
    );
  }
}
```

## JWT Token Structure Expected

The UserModel parser expects JWT tokens with the following structure:

```json
{
  "sub": "d1234",
  "empInfo": "{\"FullName\":\"John Doe\",\"Email\":\"john@example.com\",\"Role\":\"admin\",\"Department\":\"IT\",\"Designation\":\"Manager\",\"Location\":\"Ranchi\",\"PhoneNumber\":\"1234567890\"}"
}
```

- `sub` claim contains the personnel number
- `empInfo` claim contains a JSON string with employee information
- The parser handles both `PascalCase` and `camelCase` field names

## Benefits

✅ **Single Source of Truth** - One place for all user data
✅ **No Duplication** - JWT decoding happens once on login
✅ **Type Safe** - UserModel provides structured access
✅ **Performance** - Data is cached in memory
✅ **Clean Code** - No scattered SharedPreferences calls
✅ **Easy Testing** - Centralized logic is easier to test
✅ **Token Management** - Automatic expiry checking
✅ **Secure** - Tokens automatically added to API requests

## Migration Notes

All existing code has been refactored to use the new manager. No additional changes are required unless:

1. You add new screens that need user data - use `UserPreferencesManager.instance`
2. You add new API endpoints - use `_getHeaders()` method in api_service.dart
3. You need additional user fields - add them to `UserModel`

## Troubleshooting

### "User data is null"
- Check if user is logged in: `await _prefsManager.isLoggedIn()`
- Ensure token is valid and contains expected claims

### "Token expired"
- Use `await _prefsManager.isTokenExpired()` to check
- Redirect to login screen if expired

### "Need to add custom preference key"
- Use `await _prefsManager.getPreferences()` for non-user data
- Keep user-related data in UserModel

## Future Enhancements

Consider adding these features as needed:

1. **Role-based Access Control** - Add helper methods for specific roles
2. **Offline Support** - Cache user data for offline access
3. **Multiple Users** - Support switching between accounts
4. **Encryption** - Encrypt sensitive data in SharedPreferences
5. **Analytics** - Track user actions with persNo
