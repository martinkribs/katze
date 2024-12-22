import 'package:flutter/material.dart';
import 'package:katze/core/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service;
  bool _isInitialized = false;
  String? _error;

  NotificationProvider(this._service);

  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _service.notificationsEnabled;
  String? get error => _error;
  GlobalKey<NavigatorState> get navigationKey => _service.navigationKey;

  Future<void> requestPermissions() async {
    try {
      await _service.requestNotificationsPermission();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    try {
      await _service.initialize();
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isInitialized = false;
    }
    notifyListeners();
  }

  Future<void> showGameNotification({
    required String title,
    required String body,
    required String gameId,
  }) async {
    try {
      await _service.showGameNotification(
        title: title,
        body: body,
        gameId: gameId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}
