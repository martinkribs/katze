import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  // Callback for handling messages
  Function(dynamic)? onMessageReceived;

  String get _websocketUrl => AppConfig.websocketUrl;

  bool get isConnected => _isConnected;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(_websocketUrl).replace(
          queryParameters: {
            'app_key': 'TSLI9e5eMzqKzjxTGeNe',
            'app_id': 'Katze',
          },
        ),
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
