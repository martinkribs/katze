import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/core/services/deep_link_service.dart';

class GameService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService;

  GameService(this._authService);

  Future<Map<String, dynamic>> getGames(
      {int page = 1, int perPage = 10}) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/games?page=$page&per_page=$perPage'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load games: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getGameDetails(int gameId) async {
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

  Future<Map<String, dynamic>> createGame({
    required String name,
    required String description,
    required bool isPrivate,
    required String timezone,
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
        'description': description,
        'is_private': isPrivate,
        'timezone': timezone,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create game: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateGameSettings({
    required int gameId,
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

  Future<Map<String, dynamic>> startGame(int gameId) async {
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

  Future<String> createInviteLink(int gameId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/games/$gameId/invite-link'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DeepLinkService.generateGameInviteLink(data['token']);
    } else {
      throw Exception('Failed to create invite link: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> joinGame(String token) async {
    final authToken = await _authService.getToken();
    if (authToken == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/join-game/$token'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to join game');
    }
  }

  Future<String> generateWhatsAppShareText(int gameId, String gameName) async {
    final inviteLink = await createInviteLink(gameId);
    return 'Join my Cat Game "$gameName"! Click here to join: $inviteLink';
  }
}
