import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  final _storage = const FlutterSecureStorage();

  // Keys for storing authentication data
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _refreshTokenKey = 'refresh_token';

  // Encryption key for additional security (you should generate this securely)
  static const _encryptionKey = 'your_secure_encryption_key';

  // Storage options with encryption
  final _secureOptions = const AndroidOptions(
    encryptedSharedPreferences: true,
    keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  );

  // Verify email with code
  Future<bool> verifyEmail(String code) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/email/verify'),
        headers: _getAuthHeaders(token),
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Email verification failed');
      }
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  // Get current user data with token refresh handling
  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw const AuthException('No authentication token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Retry with new token
          final retryResponse = await http.get(
            Uri.parse('$_baseUrl/user'),
            headers: _getAuthHeaders(newToken),
          );
          if (retryResponse.statusCode == 200) {
            return jsonDecode(retryResponse.body);
          }
        }
        throw const AuthException('Session expired, please login again');
      } else {
        final error = jsonDecode(response.body);
        throw AuthException(error['message'] ?? 'Failed to get user data');
      }
    } catch (e) {
      throw AuthException('Network error: ${e.toString()}');
    }
  }

  // Registration with input validation
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validate input
    if (!_isValidEmail(email)) {
      throw const AuthException('Invalid email format');
    }
    if (!_isStrongPassword(password)) {
      throw const AuthException(
          'Password must be at least 8 characters long and contain numbers, letters, and special characters');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: _getBaseHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        await _saveUserData(responseBody);
        return responseBody;
      } else {
        final error = jsonDecode(response.body);
        throw AuthException(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  // Secure login with rate limiting
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (await _isRateLimited()) {
      throw const AuthException('Too many login attempts. Please try again later.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: _getBaseHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      String responseBody = response.body.trim();
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
          await _saveUserData(jsonResponse);
          await _resetLoginAttempts();
          return jsonResponse;
        } catch (e) {
          print('JSON Parse Error: $e');
          print('Response Body: $responseBody');
          throw AuthException('Invalid response format from server');
        }
      } else {
        await _incrementLoginAttempts();
        try {
          final error = jsonDecode(responseBody);
          throw AuthException(error['message'] ?? 'Login failed');
        } catch (e) {
          print('Error Response Body: $responseBody');
          throw AuthException('Login failed: Invalid server response');
        }
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  // Resend verification notification
  Future<bool> resendVerificationNotification() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/email/verify/resend'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
          'Failed to resend verification notification: ${response.body}');
    }
  }

  // Save user data securely
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    // Save token securely
    if (userData['access_token'] != null) {
      await _storage.write(
        key: _tokenKey,
        value: userData['access_token'],
        aOptions: _secureOptions,
      );
    }

    if (userData['refresh_token'] != null) {
      await _storage.write(
        key: _refreshTokenKey,
        value: userData['refresh_token'],
        aOptions: _secureOptions,
      );
    }

    // Save user details securely
    final user = userData['user'] ?? userData;
    if (user != null) {
      await _storage.write(
        key: _userIdKey,
        value: user['id'].toString(),
        aOptions: _secureOptions,
      );
      await _storage.write(
        key: _userNameKey,
        value: user['name'],
        aOptions: _secureOptions,
      );
      await _storage.write(
        key: _userEmailKey,
        value: user['email'],
        aOptions: _secureOptions,
      );
    }
  }

  // Secure token refresh
  Future<String?> _refreshToken() async {
    final refreshToken = await _storage.read(
      key: _refreshTokenKey,
      aOptions: _secureOptions,
    );
    if (refreshToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/token/refresh'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        await _saveUserData(responseBody);
        return responseBody['access_token'];
      }
    } catch (e) {
      print('Token refresh failed: ${e.toString()}');
    }
    return null;
  }

  // Helper methods
  Map<String, String> _getBaseHeaders() => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Map<String, String> _getAuthHeaders(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]')
            .hasMatch(password);
  }

  // Rate limiting implementation
  Future<bool> _isRateLimited() async {
    final attempts = await _storage.read(
          key: 'login_attempts',
          aOptions: _secureOptions,
        ) ??
        '0';
    final lastAttempt = await _storage.read(
          key: 'last_attempt_time',
          aOptions: _secureOptions,
        ) ??
        '0';

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - int.parse(lastAttempt) > 300000) {
      // Reset after 5 minutes
      await _resetLoginAttempts();
      return false;
    }

    return int.parse(attempts) >= 5;
  }

  Future<void> _incrementLoginAttempts() async {
    final attempts = await _storage.read(
          key: 'login_attempts',
          aOptions: _secureOptions,
        ) ??
        '0';
    await _storage.write(
      key: 'login_attempts',
      value: (int.parse(attempts) + 1).toString(),
      aOptions: _secureOptions,
    );
    await _storage.write(
      key: 'last_attempt_time',
      value: DateTime.now().millisecondsSinceEpoch.toString(),
      aOptions: _secureOptions,
    );
  }

  Future<void> _resetLoginAttempts() async {
    await _storage.write(
      key: 'login_attempts',
      value: '0',
      aOptions: _secureOptions,
    );
    await _storage.write(
      key: 'last_attempt_time',
      value: '0',
      aOptions: _secureOptions,
    );
  }

  // Secure logout
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        // Call logout endpoint if available
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: _getAuthHeaders(token),
        );
      } catch (e) {
        print('Logout endpoint failed: ${e.toString()}');
      }
    }
    
    // Clear all secure storage
    await _storage.deleteAll(aOptions: _secureOptions);
  }

  // Get current authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey, aOptions: _secureOptions);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Method to get current user's email
  Future<String?> getCurrentUserEmail() async {
    return await _storage.read(key: _userEmailKey, aOptions: _secureOptions);
  }
}

// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
