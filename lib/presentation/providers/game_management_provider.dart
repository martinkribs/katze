import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:katze/core/config/app_config.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/core/services/websocket_service.dart';
import 'package:katze/presentation/providers/loading_provider.dart';

class GameManagementProvider with ChangeNotifier {
  static String get _baseUrl => AppConfig.apiBaseUrl;
  final AuthService _authService;
  final LoadingProvider _loadingProvider;
  final WebSocketService _websocketService;

  List<Map<String, dynamic>> _games = [];
  Map<String, dynamic>? _currentGame;

  // Pagination state
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 10;
  int _totalGames = 0;

  GameManagementProvider(
    this._authService,
    this._loadingProvider,
    this._websocketService,
  ) {
    // Setup WebSocket message handler for game updates
    _websocketService.addMessageHandler(_handleWebSocketMessage);
  }

  // Getters
  List<Map<String, dynamic>> get games => _games;
  Map<String, dynamic>? get currentGame => _currentGame;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get perPage => _perPage;
  int get totalGames => _totalGames;

  // WebSocket message handler
  void _handleWebSocketMessage(dynamic message) {
    try {
      if (message is! Map<String, dynamic>) {
        message = jsonDecode(message.toString());
      }

      switch (message['type']) {
        case 'game_update':
          if (_currentGame != null && 
              message['gameId'].toString() == _currentGame!['id'].toString()) {
            // Reload game details if we're currently viewing this game
            loadGameDetails(_currentGame!['id'].toString());
          }
          // Refresh games list if we're on the overview
          if (_games.isNotEmpty) {
            loadGames(page: _currentPage, perPage: _perPage);
          }
          break;
        case 'game_deleted':
          if (_currentGame != null && 
              message['gameId'].toString() == _currentGame!['id'].toString()) {
            clearCurrentGame();
          }
          // Refresh games list
          if (_games.isNotEmpty) {
            loadGames(page: _currentPage, perPage: _perPage);
          }
          break;
        case 'game_started':
          if (_currentGame != null && 
              message['gameId'].toString() == _currentGame!['id'].toString()) {
            loadGameDetails(_currentGame!['id'].toString());
          }
          break;
      }
    } catch (e) {
      print('Error handling WebSocket message in GameManagementProvider: $e');
    }
  }

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

  // Load games list with pagination support
  Future<void> loadGames({int page = 1, int perPage = 10}) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

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
        notifyListeners();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load games');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Load single game details
  Future<void> loadGameDetails(String gameId) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

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
        notifyListeners();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load game details');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Create new game
  Future<void> createGame({
    required String name,
    required String description,
    required bool isPrivate,
    required String timezone,
  }) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

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
        notifyListeners();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create game');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Delete game
  Future<void> deleteGame(String gameId) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

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
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Start game
  Future<void> startGame(String gameId) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

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
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Clear current game
  void clearCurrentGame() {
    _currentGame = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up WebSocket handler
    _websocketService.removeMessageHandler(_handleWebSocketMessage);
    super.dispose();
  }
}
