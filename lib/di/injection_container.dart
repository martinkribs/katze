import 'package:get_it/get_it.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/domain/repositories/game_repository.dart';
import 'package:katze/domain/usecases/create_game.dart';
import 'package:katze/domain/usecases/join_game.dart';
import 'package:katze/domain/usecases/get_concrete_role.dart';
import 'package:katze/presentation/bloc/game/game_bloc.dart';
import 'package:katze/presentation/bloc/notification/notification_bloc.dart';
import 'package:katze/presentation/bloc/theme/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton<AuthService>(() => AuthService());

  // Blocs
  sl.registerFactory(() => GameBloc());
  sl.registerFactory(() => NotificationBloc());
  sl.registerFactory(() => ThemeBloc());

  // Use Cases
  sl.registerLazySingleton(() => CreateGame(sl()));
  sl.registerLazySingleton(() => JoinGame(sl()));
  sl.registerLazySingleton(() => GetConcreteRole());

  // Repositories
  // Note: You'll need to implement a concrete implementation of GameRepository
  sl.registerLazySingleton<GameRepository>(() => 
    throw UnimplementedError('GameRepository must be implemented')
  );
}
