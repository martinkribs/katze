import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _authToken;

  // List of callbacks for handling messages
  final List<Function(dynamic)> _messageHandlers = [];

  void addMessageHandler(Function(dynamic) handler) {
    print('Adding message handler: ${handler.hashCode}');
    _messageHandlers.add(handler);
    print('Total handlers: ${_messageHandlers.length}');
  }

  void removeMessageHandler(Function(dynamic) handler) {
    print('Removing message handler: ${handler.hashCode}');
    _messageHandlers.remove(handler);
    print('Total handlers: ${_messageHandlers.length}');
  }

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

  String? _socketId;

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
          
          try {
            final Map<String, dynamic> data = jsonDecode(message);
            
            // Handle Pusher protocol messages
            if (data['event'] == 'pusher:connection_established') {
              final connectionData = jsonDecode(data['data']);
              _socketId = connectionData['socket_id'];
              print('WebSocket connected with socket ID: $_socketId');
              
              // Subscribe to game channel
              if (_currentGameId != null) {
                subscribeToGameChannel(_currentGameId!);
              }
            }
            
            print('Number of message handlers: ${_messageHandlers.length}');
            for (var handler in _messageHandlers) {
              print('Calling message handler: ${handler.hashCode}');
              handler(message);
            }
          } catch (e) {
            print('Error processing WebSocket message: $e');
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

  String? _currentGameId;

  void subscribeToGameChannel(String gameId) {
    _currentGameId = gameId;
    if (_isConnected) {
      final subscribeMessage = {
        'event': 'pusher:subscribe',
        'data': {
          'channel': 'game.$gameId'
        }
      };
      print('Subscribing to game channel: game.$gameId');
      _channel?.sink.add(jsonEncode(subscribeMessage));
    }
  }

  void send(String message) {
    if (_isConnected) {
      print('Sending WebSocket message: $message');
      final data = jsonDecode(message);
      
      // Add socket_id to message if available
      if (_socketId != null && data['data'] != null) {
        data['data']['socket_id'] = _socketId;
      }
      
      _channel?.sink.add(jsonEncode(data));
    } else {
      print('Cannot send message: WebSocket not connected');
    }
  }
}
