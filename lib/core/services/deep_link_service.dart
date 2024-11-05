import 'dart:async';

import 'package:flutter/services.dart';
import 'package:uni_links3/uni_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  StreamSubscription? _subscription;
  final _deepLinkStreamController = StreamController<String>.broadcast();

  Stream<String> get deepLinkStream => _deepLinkStreamController.stream;

  Future<void> initialize() async {
    // Handle initial URI if the app was launched from a deep link
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri.toString());
      }
    } on PlatformException {
      print('Failed to get initial URI');
    }

    // Listen for subsequent deep links
    _subscription = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri.toString());
      }
    }, onError: (err) {
      print('Failed to handle deep link: $err');
    });
  }

  void _handleDeepLink(String link) {
    print('Received deep link: $link');
    _deepLinkStreamController.add(link);
  }

  void dispose() {
    _subscription?.cancel();
    _deepLinkStreamController.close();
  }

  // Helper methods for specific deep link types
  static String? extractVerificationToken(String link) {
    try {
      final uri = Uri.parse(link);
      if (uri.scheme == 'katze' && uri.host == 'verify-email') {
        return uri.queryParameters['token'];
      }
    } catch (e) {
      print('Failed to parse verification link: $e');
    }
    return null;
  }

  static String? extractGameInviteToken(String link) {
    try {
      final uri = Uri.parse(link);
      if (uri.scheme == 'katze' && uri.host == 'game-invite') {
        return uri.queryParameters['token'];
      }
    } catch (e) {
      print('Failed to parse game invite link: $e');
    }
    return null;
  }

  // Generate deep link URLs
  static String generateVerificationUrl(String token) {
    return 'katze://verify-email?token=$token';
  }

  static String generateGameInviteUrl(String token) {
    return 'katze://game-invite?token=$token';
  }
}
