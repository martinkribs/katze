import 'package:katze/domain/entities/game_instance.dart';
import 'package:katze/domain/repositories/game_repository.dart';

class JoinGame {
  final GameRepository repository;

  JoinGame(this.repository);

  Future<GameInstance> call({
    required String gameId,
    required String userId,
  }) async {
    // Validate input
    if (gameId.isEmpty) {
      throw ArgumentError('Game ID cannot be empty');
    }

    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    // Join game through repository
    return await repository.joinGame(
      gameId: gameId,
      userId: userId,
    );
  }
}
