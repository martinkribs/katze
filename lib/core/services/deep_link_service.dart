import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  final _navigationKey = GlobalKey<NavigatorState>();
  final _deepLinkStreamController = StreamController<String>.broadcast();

  GlobalKey<NavigatorState> get navigationKey => _navigationKey;
  Stream<String> get deepLinkStream => _deepLinkStreamController.stream;

  Future<void> initialize() async {
    // Handle initial link if app was launched from a deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('Failed to get initial URI: $e');
    }

    // Listen for subsequent deep links
    _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (e) => print('Deep link error: $e'),
    );
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host == 'game-invite') {
      final gameId = uri.queryParameters['gameId'];
      if (gameId != null) {
        _navigationKey.currentState?.pushNamed('/game', arguments: gameId);
        _deepLinkStreamController.add(uri.toString());
      }
    }
  }

  static String generateGameInviteLink(String gameId) {
    if (gameId.isEmpty) {
      throw ArgumentError('Game ID cannot be empty');
    }
    final encodedGameId = Uri.encodeComponent(gameId);
    return 'katze://game-invite?gameId=$encodedGameId';
  }

  void dispose() {
    _deepLinkStreamController.close();
  }
}
