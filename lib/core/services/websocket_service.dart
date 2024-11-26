import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String _localUrl = 'ws://10.0.2.2:6001/app/your-pusher-key';
  final String _prodUrl = 'wss://soketi.katze.app/your-pusher-key';
  bool _isConnected = false;

  // Callback for handling messages
  Function(dynamic)? onMessageReceived;

  String get _websocketUrl {
    if (kDebugMode) {
      return _localUrl;
    }
    return _prodUrl;
  }

  bool get isConnected => _isConnected;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(_websocketUrl),
      );
      _isConnected = true;

      // Listen for messages
      _channel?.stream.listen(
        (message) {
          if (onMessageReceived != null) {
            onMessageReceived!(message);
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _isConnected = false;
          // Try to reconnect after error
          Future.delayed(const Duration(seconds: 5), () {
            if (!_isConnected) {
              connect();
            }
          });
        },
        onDone: () {
          _isConnected = false;
          // Try to reconnect when connection is closed
          Future.delayed(const Duration(seconds: 5), () {
            if (!_isConnected) {
              connect();
            }
          });
        },
      );
    } catch (e) {
      print('WebSocket Connection Error: $e');
      _isConnected = false;
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  void send(String message) {
    if (_isConnected) {
      _channel?.sink.add(message);
    }
  }
}
