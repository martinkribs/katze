import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:katze/core/services/auth_service.dart';

class GameRepository {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService;

  GameRepository(this._authService);

  Future<List<Map<String, dynamic>>> getGames() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> games = jsonDecode(response.body);
      return games.cast<Map<String, dynamic>>();
    } else if (response.statusCode == 404) {
      throw Exception('API endpoint not found. Please ensure the backend service is running and configured correctly.');
    } else {
      throw Exception('Failed to load games: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getGameDetails(String gameId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/games/$gameId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Game not found or API endpoint not available. Please check the game ID and backend service.');
    } else {
      throw Exception('Failed to load game details: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createGame({
    required String name,
    required Map<String, dynamic> settings,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'settings': settings,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('API endpoint not found. Please ensure the backend service is running and configured correctly.');
    } else {
      throw Exception('Failed to create game: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateGameSettings({
    required String gameId,
    required Map<String, dynamic> settings,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/games/$gameId/settings'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(settings),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Game not found or API endpoint not available. Please check the game ID and backend service.');
    } else {
      throw Exception('Failed to update game settings: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> startGame(String gameId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/games/$gameId/start'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Game not found or API endpoint not available. Please check the game ID and backend service.');
    } else {
      throw Exception('Failed to start game: ${response.body}');
    }
  }

  String generateInviteLink(String gameId) {
    return 'katze://game-invite?id=$gameId';
  }

  String generateWhatsAppShareText(String gameId, String gameName) {
    final inviteLink = generateInviteLink(gameId);
    return 'Join my Cat Game "$gameName"! Click here to join: $inviteLink';
  }
}
