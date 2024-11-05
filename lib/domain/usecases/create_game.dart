import 'package:katze/domain/entities/game_instance.dart';
import 'package:katze/domain/repositories/game_repository.dart';

class CreateGame {
  final GameRepository repository;

  CreateGame(this.repository);

  Future<GameInstance> call({
    required String name,
    required String gameMasterId,
    Map<String, dynamic>? customRules,
  }) async {
    // Validate input
    if (name.isEmpty) {
      throw ArgumentError('Game name cannot be empty');
    }

    if (gameMasterId.isEmpty) {
      throw ArgumentError('Game master ID cannot be empty');
    }

    // Create game through repository
    return await repository.createGame(
      name: name,
      gameMasterId: gameMasterId,
      customRules: customRules,
    );
  }
}
