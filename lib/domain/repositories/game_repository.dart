import 'package:katze/domain/entities/game_instance.dart';
import 'package:katze/domain/entities/player.dart';
import 'package:katze/domain/entities/role.dart';

abstract class GameRepository {
  Future<GameInstance> createGame({
    required String name,
    required String gameMasterId,
    Map<String, dynamic>? customRules,
  });

  Future<GameInstance> joinGame({
    required String gameId,
    required String userId,
  });

  Future<GameInstance> startGame({
    required String gameId,
  });

  Future<GameInstance> assignRoles({
    required String gameId,
  });

  Future<List<GameInstance>> getUserGames({
    required String userId,
  });

  Future<GameInstance> getGameDetails({
    required String gameId,
  });

  Future<GameInstance> updateGameStatus({
    required String gameId,
    required GameStatus newStatus,
  });

  Future<Player> addPlayerToGame({
    required String gameId,
    required Player player,
  });

  Future<List<Role>> generateRolesForGame({
    required int playerCount,
  });

  Future<void> endGame({
    required String gameId,
  });
}
