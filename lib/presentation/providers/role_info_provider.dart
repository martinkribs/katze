import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:katze/core/config/app_config.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/providers/loading_provider.dart';

class RoleInfoProvider with ChangeNotifier {
  static String get _baseUrl => AppConfig.apiBaseUrl;
  final AuthService _authService;
  final LoadingProvider _loadingProvider;

  final Map<String, Map<String, dynamic>> _roleActionTypesCache = {};
  List<Map<String, dynamic>> _roles = [];

  RoleInfoProvider(this._authService, this._loadingProvider);

  List<Map<String, dynamic>> get roles => _roles;
  Map<String, Map<String, dynamic>> get roleActionTypesCache => _roleActionTypesCache;

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

  Future<void> loadRoles() async {
    if (_roles.isNotEmpty) return; // Return if roles are already loaded

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
          if (teamRoles is List) {
            _roles.addAll(
              teamRoles.map((role) => Map<String, dynamic>.from(role))
            );
          }
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

  Future<Map<String, dynamic>> getRoleActionTypes(String roleId) async {
    // Return cached data if available
    if (_roleActionTypesCache.containsKey(roleId)) {
      return _roleActionTypesCache[roleId]!;
    }

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/roles/$roleId/action-types'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _roleActionTypesCache[roleId] = Map<String, dynamic>.from(data);
        notifyListeners();
        return _roleActionTypesCache[roleId]!;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load role action types');
      }
    } catch (e) {
      rethrow;
    }
  }

  void clearCache() {
    _roleActionTypesCache.clear();
    _roles.clear();
    notifyListeners();
  }
}
