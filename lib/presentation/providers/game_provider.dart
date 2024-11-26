import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:katze/core/services/auth_service.dart';

import '../../core/services/deep_link_service.dart';

class GameProvider with ChangeNotifier {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService;

  List<Map<String, dynamic>> _games = [];
  Map<String, dynamic>? _currentGame;
  List<Map<String, dynamic>> _roles = [];
  Map<String, dynamic>? _currentGameSettings;
  Map<String, dynamic>? _roleActionTypes;
  bool _isLoading = false;
  String? _error;

  // Pagination state
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 10;
  int _totalGames = 0;

  GameProvider(this._authService);

  // Getters
  List<Map<String, dynamic>> get games => _games;
  Map<String, dynamic>? get currentGame => _currentGame;
  List<Map<String, dynamic>> get roles => _roles;
  Map<String, dynamic>? get currentGameSettings => _currentGameSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get perPage => _perPage;
  int get totalGames => _totalGames;
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

  // Perform game action
  Future<Map<String, dynamic>> performAction({
    required String gameId,
    required String targetId,
    required String actionType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/games/$gameId/actions'),
        headers: headers,
        body: jsonEncode({
          'targets': [targetId],
          'action_type_id': actionType,
        }),
      );

      if (response.statusCode == 200) {
        final result = Map<String, dynamic>.from(jsonDecode(response.body));
        // Refresh game details to get updated state
        await loadGameDetails(gameId);
        return result;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to perform action');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Leave game
  Future<void> leaveGame(String gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load role action types
  Future<void> loadRoleActionTypes(String roleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/roles/$roleId/action-types'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store the action types directly
        _roleActionTypes = Map<String, dynamic>.from(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load role action types');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load games list with pagination support
  Future<void> loadGames({int page = 1, int perPage = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/games?page=$page&per_page=$perPage'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update pagination info from meta
        final meta = data['meta'];
        _currentPage = meta['current_page'];
        _lastPage = meta['last_page'];
        _perPage = meta['per_page'];
        _totalGames = meta['total'];

        // Cast the games list properly
        final List<dynamic> gamesList = data['games'] ?? [];
        _games = List<Map<String, dynamic>>.from(
            gamesList.map((game) => Map<String, dynamic>.from(game)));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load games');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load single game details
  Future<void> loadGameDetails(String gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/games/$gameId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Find current user's role from players array
        if (data['currentUser'] != null && data['players'] != null) {
          final currentUserId = data['currentUser']['id'];
          final List<dynamic> players = data['players'];

          // Find the current player's data
          for (var player in players) {
            if (player['id'] == currentUserId) {
              // Copy role information from players array to currentUser
              data['currentUser']['role'] = player['role'];
              break;
            }
          }
        }

        // Store the complete response data
        _currentGame = Map<String, dynamic>.from(data);

        // Load role action types if user has a role and game is in progress or user is not game master
        if (_currentGame?['currentUser']?['role']?['id'] != null &&
            (_currentGame?['status'] == 'in_progress' ||
                _currentGame?['currentUser']?['isGameMaster'] == false)) {
          await loadRoleActionTypes(
              _currentGame!['currentUser']['role']['id'].toString());
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load game details');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load game settings
  Future<void> loadGameSettings(String gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/games/$gameId/settings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentGameSettings = Map<String, dynamic>.from(data['settings']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load game settings');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load available roles
  Future<void> loadRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load roles');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update game settings
  Future<void> updateGameSettings({
    required String gameId,
    required bool useDefault,
    required Map<String, int> roleConfiguration,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new game
  Future<void> createGame({
    required String name,
    required String description,
    required bool isPrivate,
    required String timezone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/games'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'is_private': isPrivate,
          'timezone': timezone,
        }),
      );

      if (response.statusCode == 201) {
        _currentGame = Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create game');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete game
  Future<void> deleteGame(String gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/games/$gameId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete game');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start game
  Future<void> startGame(String gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/games/$gameId/start'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await loadGameDetails(gameId);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to start game');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create and get invite link
  Future<Map<String, dynamic>> createInviteLink(String gameId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/games/$gameId/invite-link'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));
        return {
          'token': data['token'],
          'inviteLink': data['invite_link'],
          'expiresAt': data['expires_at'],
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create invite link');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Join game with invite token
  Future<Map<String, dynamic>> joinGame(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/join-game/$token'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));
        final game = Map<String, dynamic>.from(data['game']);
        await loadGameDetails(game['id'].toString());
        return game;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to join game');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate WhatsApp share text
  Future<String> generateWhatsAppShareText(
      String gameId, String gameName) async {
    final inviteData = await createInviteLink(gameId);
    return 'Join my Cat Game "$gameName"! Click here to join: ${DeepLinkService.generateGameInviteLink(inviteData['token'])}';
  }

  // Clear current game
  void clearCurrentGame() {
    _currentGame = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
