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

  // Play Store URL for the app
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=app.katze.game';

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
    // Handle both app scheme and https scheme
    if (uri.host == 'open.katze.app' && uri.path.startsWith('/game-invite')) {
      String? token = uri.queryParameters['token'];

      if (token != null) {
        _navigationKey.currentState?.pushNamed('/join-game', arguments: token);
        _deepLinkStreamController.add(uri.toString());
      }
    }
  }

  static String generateGameInviteLink(String token) {
    if (token.isEmpty) {
      throw ArgumentError('Token cannot be empty');
    }
    // Generate web URL that will either open the app or redirect to Play Store
    return 'Join Cat Game - https://open.katze.app/game-invite?token=$token';
  }

  void dispose() {
    _deepLinkStreamController.close();
  }
}
