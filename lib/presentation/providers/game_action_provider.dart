import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/providers/loading_provider.dart';
import 'package:katze/presentation/providers/game_management_provider.dart';

class GameActionProvider with ChangeNotifier {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService;
  final LoadingProvider _loadingProvider;
  final GameManagementProvider _gameManagementProvider;

  List<Map<String, dynamic>> _roles = [];
  Map<String, dynamic>? _roleActionTypes;

  GameActionProvider(
    this._authService,
    this._loadingProvider,
    this._gameManagementProvider,
  );

  // Getters
  List<Map<String, dynamic>> get roles => _roles;
  Map<String, dynamic>? get roleActionTypes => _roleActionTypes;

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

  // Load role action types
  Future<void> loadRoleActionTypes(String roleId) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/roles/$roleId/action-types'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _roleActionTypes = Map<String, dynamic>.from(data);
        notifyListeners();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load role action types');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Load available roles
  Future<void> loadRoles() async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/roles'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rolesData = data['roles'] as Map<String, dynamic>;

        // Flatten roles from all teams into a single list
        _roles = [];
        for (var teamRoles in rolesData.values) {
          final List<dynamic> teamRolesList = teamRoles;
          _roles.addAll(
              teamRolesList.map((role) => Map<String, dynamic>.from(role)));
        }
        notifyListeners();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load roles');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Perform game action
  Future<Map<String, dynamic>> performAction({
    required String gameId,
    required String targetId,
    required String actionType,
  }) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/games/$gameId/actions'),
        headers: headers,
        body: jsonEncode({
          'targets': [targetId],
          'action_type_id': actionType,
        }),
      );

      if (response.statusCode == 200) {
        final result = Map<String, dynamic>.from(jsonDecode(response.body));
        // Refresh game details to get updated state
        await _gameManagementProvider.loadGameDetails(gameId);
        return result;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to perform action');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Kick player from game
  Future<void> kickPlayer(String gameId, String playerId) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/games/$gameId/kick/$playerId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to kick player');
      }

      // Refresh game details after kicking player
      await _gameManagementProvider.loadGameDetails(gameId);
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Leave game
  Future<void> leaveGame(String gameId) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/games/$gameId/leave'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to leave game');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }
}
