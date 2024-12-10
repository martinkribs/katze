import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/providers/loading_provider.dart';

class GameSettingsProvider with ChangeNotifier {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService;
  final LoadingProvider _loadingProvider;

  Map<String, dynamic>? _currentGameSettings;

  GameSettingsProvider(this._authService, this._loadingProvider);

  // Getters
  Map<String, dynamic>? get currentGameSettings => _currentGameSettings;

  // Helper method for API calls
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Load game settings
  Future<void> loadGameSettings(String gameId) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/games/$gameId/settings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentGameSettings = Map<String, dynamic>.from(data['settings']);
        notifyListeners();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load game settings');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Update game settings
  Future<void> updateGameSettings({
    required String gameId,
    required bool useDefault,
    required Map<String, int> roleConfiguration,
  }) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/games/$gameId/settings'),
        headers: headers,
        body: jsonEncode({
          'use_default': useDefault,
          'role_configuration': roleConfiguration,
        }),
      );

      if (response.statusCode == 200) {
        await loadGameSettings(gameId);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update game settings');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }
}
