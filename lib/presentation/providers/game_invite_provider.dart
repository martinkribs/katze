import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:katze/core/config/app_config.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/core/services/deep_link_service.dart';
import 'package:katze/presentation/providers/loading_provider.dart';
import 'package:katze/presentation/providers/game_management_provider.dart';

class GameInviteProvider with ChangeNotifier {
  static String get _baseUrl => AppConfig.apiBaseUrl;
  final AuthService _authService;
  final LoadingProvider _loadingProvider;
  final GameManagementProvider _gameManagementProvider;

  GameInviteProvider(
    this._authService,
    this._loadingProvider,
    this._gameManagementProvider,
  );

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
      _loadingProvider.setError(e.toString());
      rethrow;
    }
  }

  // Join game with invite token
  Future<Map<String, dynamic>> joinGame(String token) async {
    _loadingProvider.setLoading(true);
    _loadingProvider.clearError();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/join-game/$token'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));
        final game = Map<String, dynamic>.from(data['game']);
        await _gameManagementProvider.loadGameDetails(game['id'].toString());
        return game;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to join game');
      }
    } catch (e) {
      _loadingProvider.setError(e.toString());
      rethrow;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  // Generate WhatsApp share text
  Future<String> generateWhatsAppShareText(
      String gameId, String gameName) async {
    final inviteData = await createInviteLink(gameId);
    return 'Join my Cat Game "$gameName"! Click here to join: ${DeepLinkService.generateGameInviteLink(inviteData['token'])}';
  }
}
