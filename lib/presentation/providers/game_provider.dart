import 'package:flutter/foundation.dart';
import 'package:katze/data/repositories/game_repository.dart';

class GameProvider with ChangeNotifier {
  final GameRepository _repository;
  List<Map<String, dynamic>> _games = [];
  Map<String, dynamic>? _currentGame;
  bool _isLoading = false;
  String? _error;

  GameProvider(this._repository);

  List<Map<String, dynamic>> get games => _games;
  Map<String, dynamic>? get currentGame => _currentGame;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGames() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _games = await _repository.getGames();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGameDetails(String gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentGame = await _repository.getGameDetails(gameId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGame({
    required String name,
    required Map<String, dynamic> settings,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newGame = await _repository.createGame(
        name: name,
        settings: settings,
      );
      _games = [..._games, newGame];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGameSettings({
    required String gameId,
    required Map<String, dynamic> settings,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedGame = await _repository.updateGameSettings(
        gameId: gameId,
        settings: settings,
      );
      
      if (_currentGame != null && _currentGame!['id'] == gameId) {
        _currentGame = updatedGame;
      }
      
      _games = _games.map((game) {
        if (game['id'] == gameId) {
          return updatedGame;
        }
        return game;
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startGame(String gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final startedGame = await _repository.startGame(gameId);
      
      if (_currentGame != null && _currentGame!['id'] == gameId) {
        _currentGame = startedGame;
      }
      
      _games = _games.map((game) {
        if (game['id'] == gameId) {
          return startedGame;
        }
        return game;
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String generateInviteLink(String gameId) {
    return _repository.generateInviteLink(gameId);
  }

  String generateWhatsAppShareText(String gameId, String gameName) {
    return _repository.generateWhatsAppShareText(gameId, gameName);
  }
}
