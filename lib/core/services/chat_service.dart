import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'websocket_service.dart';
import 'auth_service.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isNightChat;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isNightChat = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isNightChat: json['isNightChat'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isNightChat': isNightChat,
    };
  }
}

class ChatService {
  final WebSocketService _webSocketService;
  final AuthService _authService;
  void Function(ChatMessage)? onMessageReceived;

  ChatService(this._webSocketService, this._authService, {this.onMessageReceived}) {
    _webSocketService.addMessageHandler(_handleWebSocketMessage);
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      debugPrint('ChatService received message: $message');
      final Map<String, dynamic> data = jsonDecode(message);
      debugPrint('ChatService parsed data: $data');
      
      // Handle Pusher message format
      if (data['event'] == 'client-message' && data['data'] != null) {
        final messageData = jsonDecode(data['data']);
        debugPrint('ChatService found client-message: $messageData');
        if (messageData['type'] == 'MessageSent') {
          debugPrint('ChatService found MessageSent type');
          final chatMessage = ChatMessage.fromJson(messageData['message']);
          debugPrint('ChatService created ChatMessage: $chatMessage');
          onMessageReceived?.call(chatMessage);
          debugPrint('ChatService called onMessageReceived');
        }
      } else {
        debugPrint('ChatService ignoring message of type: ${data['type']}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error handling chat message: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void sendMessage(String gameId, String content, {bool isNightChat = false}) {
    final message = {
      'event': 'client-message',
      'channel': 'game.$gameId',
      'data': {
        'game_id': gameId,
        'content': content,
        'is_night_chat': isNightChat,
      },
    };
    _webSocketService.send(jsonEncode(message));
  }

  Future<List<ChatMessage>> loadMessages(String gameId, {
    bool isNightChat = false,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'night_chat': isNightChat.toString(),
      };

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/games/$gameId/messages')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> messages = data['data'];
        return messages.map((msg) => ChatMessage.fromJson(msg)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading messages: $e');
      return [];
    }
  }
}
