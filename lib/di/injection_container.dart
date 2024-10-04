import 'package:get_it/get_it.dart';
import 'package:katze/presentation/bloc/theme/theme_bloc.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => ThemeBloc());

  // Use Cases
  // sl.registerLazySingleton(() => StartGameUseCase(sl()));

  // Repositories
  // sl.registerLazySingleton<GameRepository>(() => GameRepositoryImpl(sl()));

  // Data Sources
  // sl.registerLazySingleton<GameDataSource>(() => GameDataSourceImpl());

  // External
  // sl.registerLazySingleton(() => http.Client());
}