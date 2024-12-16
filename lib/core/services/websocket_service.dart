import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _authToken;

  // Callback for handling messages
  Function(dynamic)? onMessageReceived;

  String get _websocketUrl => AppConfig.websocketUrl;

  bool get isConnected => _isConnected;

  void setAuthToken(String? token) {
    _authToken = token;
    // Reconnect with new token if we were previously connected
    if (_isConnected) {
      disconnect();
      connect();
    }
  }

  void connect() {
    if (_authToken == null) {
      print('Cannot connect to WebSocket without auth token');
      return;
    }

    try {
      final uri = Uri.parse(_websocketUrl);

      print('Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      // Listen for messages
      _channel?.stream.listen(
        (message) {
          print('WebSocket message received: $message');
          if (onMessageReceived != null) {
            onMessageReceived!(message);
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _isConnected = false;
          // Try to reconnect after error with exponential backoff
          Future.delayed(const Duration(seconds: 5), () {
            if (!_isConnected && _authToken != null) {
              connect();
            }
          });
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          // Try to reconnect when connection is closed with exponential backoff
          Future.delayed(const Duration(seconds: 5), () {
            if (!_isConnected && _authToken != null) {
              connect();
            }
          });
        },
      );
    } catch (e) {
      print('WebSocket Connection Error: $e');
      _isConnected = false;
      // Try to reconnect after error with exponential backoff
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isConnected && _authToken != null) {
          connect();
        }
      });
    }
  }

  void disconnect() {
    print('Disconnecting WebSocket');
    _channel?.sink.close();
    _isConnected = false;
  }

  void send(String message) {
    if (_isConnected) {
      print('Sending WebSocket message: $message');
      _channel?.sink.add(message);
    } else {
      print('Cannot send message: WebSocket not connected');
    }
  }
}
