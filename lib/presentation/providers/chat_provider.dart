import 'package:flutter/foundation.dart';
import '../../core/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  final Map<String, List<ChatMessage>> _gameMessages = {};
  final Map<String, List<ChatMessage>> _nightMessages = {};
  String? _currentGameId;
  String? get currentGameId => _currentGameId;

  bool _isLoadingGameMessages = false;
  bool _isLoadingNightMessages = false;
  int _currentGamePage = 1;
  int _currentNightPage = 1;
  bool _hasMoreGameMessages = true;
  bool _hasMoreNightMessages = true;
  static const int _perPage = 50;

  ChatProvider(this._chatService) {
    _chatService.onMessageReceived = _handleNewMessage;
  }

  List<ChatMessage> getGameMessages(String gameId) => _gameMessages[gameId] ?? [];
  List<ChatMessage> getNightMessages(String gameId) => _nightMessages[gameId] ?? [];

  bool get isLoadingGameMessages => _isLoadingGameMessages;
  bool get isLoadingNightMessages => _isLoadingNightMessages;
  bool get hasMoreGameMessages => _hasMoreGameMessages;
  bool get hasMoreNightMessages => _hasMoreNightMessages;

  Future<void> setCurrentGame(String gameId) async {
    _currentGameId = gameId;
    _currentGamePage = 1;
    _currentNightPage = 1;
    _hasMoreGameMessages = true;
    _hasMoreNightMessages = true;
    
    if (!_gameMessages.containsKey(gameId)) {
      _gameMessages[gameId] = [];
    }
    if (!_nightMessages.containsKey(gameId)) {
      _nightMessages[gameId] = [];
    }

    // Load initial messages
    await Future.wait([
      loadMoreGameMessages(),
      loadMoreNightMessages(),
    ]);
    
    notifyListeners();
  }

  Future<void> loadMoreGameMessages() async {
    if (_currentGameId == null || _isLoadingGameMessages || !_hasMoreGameMessages) return;

    _isLoadingGameMessages = true;
    notifyListeners();

    try {
      final messages = await _chatService.loadMessages(
        _currentGameId!,
        isNightChat: false,
        page: _currentGamePage,
        perPage: _perPage,
      );

      if (messages.isEmpty) {
        _hasMoreGameMessages = false;
      } else {
        _gameMessages[_currentGameId!]?.addAll(messages);
        _currentGamePage++;
      }
    } finally {
      _isLoadingGameMessages = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNightMessages() async {
    if (_currentGameId == null || _isLoadingNightMessages || !_hasMoreNightMessages) return;

    _isLoadingNightMessages = true;
    notifyListeners();

    try {
      final messages = await _chatService.loadMessages(
        _currentGameId!,
        isNightChat: true,
        page: _currentNightPage,
        perPage: _perPage,
      );

      if (messages.isEmpty) {
        _hasMoreNightMessages = false;
      } else {
        _nightMessages[_currentGameId!]?.addAll(messages);
        _currentNightPage++;
      }
    } finally {
      _isLoadingNightMessages = false;
      notifyListeners();
    }
  }

  void _handleNewMessage(ChatMessage message) {
    debugPrint('ChatProvider handling new message: $message');
    if (_currentGameId == null) {
      debugPrint('ChatProvider: No current game ID set');
      return;
    }

    debugPrint('ChatProvider: Current game ID: $_currentGameId');
    if (message.isNightChat) {
      debugPrint('ChatProvider: Adding night message');
      _nightMessages[_currentGameId]?.insert(0, message);
    } else {
      debugPrint('ChatProvider: Adding game message');
      _gameMessages[_currentGameId]?.insert(0, message);
    }
    debugPrint('ChatProvider: Notifying listeners');
    notifyListeners();
  }

  void sendMessage(String content, {bool isNightChat = false}) {
    debugPrint('ChatProvider: Sending message - content: $content, isNightChat: $isNightChat');
    if (_currentGameId == null) {
      debugPrint('ChatProvider: Cannot send message - no current game ID');
      return;
    }
    debugPrint('ChatProvider: Sending message to ChatService');
    _chatService.sendMessage(_currentGameId!, content, isNightChat: isNightChat);
  }

  void clearMessages() {
    _gameMessages.clear();
    _nightMessages.clear();
    _currentGameId = null;
    _currentGamePage = 1;
    _currentNightPage = 1;
    _hasMoreGameMessages = true;
    _hasMoreNightMessages = true;
    notifyListeners();
  }
}
