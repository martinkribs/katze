import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/di/injection_container.dart';

class GameService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  final _authService = sl<AuthService>();

  // Get list of games
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
    } else {
      throw Exception('Failed to load games: ${response.body}');
    }
  }

  // Get game details
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
    } else {
      throw Exception('Failed to load game details: ${response.body}');
    }
  }

  // Create new game
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
    } else {
      throw Exception('Failed to create game: ${response.body}');
    }
  }

  // Update game settings
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
    } else {
      throw Exception('Failed to update game settings: ${response.body}');
    }
  }

  // Start game
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
    } else {
      throw Exception('Failed to start game: ${response.body}');
    }
  }

  // Generate game invite link
  String generateInviteLink(String gameId) {
    return 'katze://game-invite?id=$gameId';
  }

  // Generate WhatsApp share text
  String generateWhatsAppShareText(String gameId, String gameName) {
    final inviteLink = generateInviteLink(gameId);
    return 'Join my Cat Game "$gameName"! Click here to join: $inviteLink';
  }
}
