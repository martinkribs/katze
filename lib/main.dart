import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/core/services/deep_link_service.dart';
import 'package:katze/core/services/game_service.dart';
import 'package:katze/core/services/notification_service.dart';
import 'package:katze/data/repositories/game_repository.dart';
import 'package:katze/presentation/pages/game_page.dart';
import 'package:katze/presentation/pages/game_settings_page.dart';
import 'package:katze/presentation/pages/verification_required_page.dart';
import 'package:katze/presentation/providers/game_provider.dart';
import 'package:katze/presentation/providers/notification_provider.dart';
import 'package:katze/presentation/providers/theme_provider.dart';
import 'package:katze/presentation/widgets/join_game_modal.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/services/auth_state_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Services initialisieren
  final authService = AuthService();
  final gameService = GameService(authService);
  final gameRepository = GameRepository(authService);
  final deepLinkService = DeepLinkService();
  final notificationService = NotificationService();
  tz.initializeTimeZones();

  // Parallel initialisieren für bessere Performance
  await Future.wait([
    deepLinkService.initialize(),
    notificationService.initialize(),
  ]);

  runApp(MyApp(
    services: AppServices(
      deepLinkService: deepLinkService,
      notificationService: notificationService,
      authService: authService,
      gameService: gameService,
      gameRepository: gameRepository,
    ),
  ));
}

// Neue Klasse für bessere Organisation der Services
class AppServices {
  final DeepLinkService deepLinkService;
  final NotificationService notificationService;
  final AuthService authService;
  final GameService gameService;
  final GameRepository gameRepository;

  const AppServices({
    required this.deepLinkService,
    required this.notificationService,
    required this.authService,
    required this.gameService,
    required this.gameRepository,
  });
}

class MyApp extends StatelessWidget {
  final AppServices services;

  const MyApp({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>.value(value: services.authService),
        Provider<GameService>.value(value: services.gameService),
        Provider<DeepLinkService>.value(value: services.deepLinkService),
        Provider<NotificationService>.value(
            value: services.notificationService),
        Provider<GameRepository>.value(value: services.gameRepository),

        // State Provider
        ChangeNotifierProvider(
          create: (context) => GameProvider(services.gameRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthStateManager(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              NotificationProvider(services.notificationService),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: services.deepLinkService.navigationKey,
            title: 'Cat Game',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('de'),
            ],
            theme: themeProvider.themeData,
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthCheckScreen(),
              '/game': (context) {
                final gameId =
                    ModalRoute.of(context)?.settings.arguments as int;
                return GamePage(gameId: gameId);
              },
              '/verify-email': (context) => const VerificationRequiredPage(),
              '/game-settings': (context) {
                final gameId =
                    ModalRoute.of(context)?.settings.arguments as int;
                return GameSettingsPage(gameId: gameId);
              },
              '/join-game': (context) {
                final token =
                    ModalRoute.of(context)?.settings.arguments as String;
                
                // Show join game modal
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => JoinGameModal(
                      token: token,
                      gameService: services.gameService,
                    ),
                  );
                });

                // Return empty scaffold while modal is shown
                return const Scaffold(
                  body: SizedBox(),
                );
              },
            },
          );
        },
      ),
    );
  }
}
