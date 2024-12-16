import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/core/services/deep_link_service.dart';
import 'package:katze/core/services/notification_service.dart';
import 'package:katze/core/services/websocket_service.dart';
import 'package:katze/presentation/pages/game_page.dart';
import 'package:katze/presentation/pages/game_settings_page.dart';
import 'package:katze/presentation/pages/verification_required_page.dart';
import 'package:katze/presentation/providers/loading_provider.dart';
import 'package:katze/presentation/providers/game_management_provider.dart';
import 'package:katze/presentation/providers/game_settings_provider.dart';
import 'package:katze/presentation/providers/game_action_provider.dart';
import 'package:katze/presentation/providers/game_invite_provider.dart';
import 'package:katze/presentation/providers/notification_provider.dart';
import 'package:katze/presentation/providers/role_info_provider.dart';
import 'package:katze/presentation/providers/theme_provider.dart';
import 'package:katze/presentation/widgets/join_game_modal.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/services/auth_state_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services in the correct order
  final websocketService = WebSocketService();
  final authService = AuthService(websocketService);
  final deepLinkService = DeepLinkService();
  final notificationService = NotificationService();
  tz.initializeTimeZones();

  // Initialize services that require async setup
  await Future.wait([
    deepLinkService.initialize(),
    notificationService.initialize(),
  ]);

  // Setup WebSocket message handler
  websocketService.onMessageReceived = (message) {
    try {
      final Map<String, dynamic> data = message as Map<String, dynamic>;
      
      // Handle different message types
      switch (data['type']) {
        case 'notification':
          notificationService.showGameNotification(
            title: data['title'] ?? 'Game Update',
            body: data['body'] ?? 'You have a new game update',
            gameId: data['gameId']?.toString() ?? '0',
          );
          break;
        default:
          // Other message types will be handled by their respective providers
          break;
      }
    } catch (e) {
      print('Error processing WebSocket message: $e');
    }
  };

  runApp(MyApp(
    services: AppServices(
      deepLinkService: deepLinkService,
      notificationService: notificationService,
      authService: authService,
      websocketService: websocketService,
    ),
  ));
}

// Services container class
class AppServices {
  final DeepLinkService deepLinkService;
  final NotificationService notificationService;
  final AuthService authService;
  final WebSocketService websocketService;

  const AppServices({
    required this.deepLinkService,
    required this.notificationService,
    required this.authService,
    required this.websocketService,
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
        Provider<DeepLinkService>.value(value: services.deepLinkService),
        Provider<NotificationService>.value(value: services.notificationService),
        Provider<WebSocketService>.value(value: services.websocketService),
        
        // Game-related Providers with proper dependency order
        ChangeNotifierProvider(
          create: (_) => LoadingProvider(),
        ),
        ChangeNotifierProxyProvider3<AuthService, LoadingProvider, WebSocketService, GameManagementProvider>(
          create: (context) => GameManagementProvider(
            services.authService,
            context.read<LoadingProvider>(),
            services.websocketService,
          ),
          update: (_, authService, loadingProvider, websocketService, previous) => previous!,
        ),
        ChangeNotifierProxyProvider2<AuthService, LoadingProvider, GameSettingsProvider>(
          create: (context) => GameSettingsProvider(
            services.authService,
            context.read<LoadingProvider>(),
          ),
          update: (_, authService, loadingProvider, previous) => previous!,
        ),
        ChangeNotifierProxyProvider2<AuthService, LoadingProvider, RoleInfoProvider>(
          create: (context) => RoleInfoProvider(
            services.authService,
            context.read<LoadingProvider>(),
          ),
          update: (_, authService, loadingProvider, previous) => previous!,
        ),
        ChangeNotifierProxyProvider3<AuthService, LoadingProvider, GameManagementProvider, GameActionProvider>(
          create: (context) => GameActionProvider(
            services.authService,
            context.read<LoadingProvider>(),
            context.read<GameManagementProvider>(),
          ),
          update: (_, authService, loadingProvider, gameManagementProvider, previous) => previous!,
        ),
        ChangeNotifierProxyProvider3<AuthService, LoadingProvider, GameManagementProvider, GameInviteProvider>(
          create: (context) => GameInviteProvider(
            services.authService,
            context.read<LoadingProvider>(),
            context.read<GameManagementProvider>(),
          ),
          update: (_, authService, loadingProvider, gameManagementProvider, previous) => previous!,
        ),
        
        // Other Providers
        ChangeNotifierProvider(
          create: (context) => AuthStateManager(services.authService),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(services.notificationService),
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
                final gameId = ModalRoute.of(context)?.settings.arguments as int;
                return GamePage(gameId: gameId);
              },
              '/verify-email': (context) => const VerificationRequiredPage(),
              '/game-settings': (context) {
                final gameId = ModalRoute.of(context)?.settings.arguments as int;
                return GameSettingsPage(gameId: gameId);
              },
              '/join-game': (context) {
                final token = ModalRoute.of(context)?.settings.arguments as String;

                // Show join game modal
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => JoinGameModal(
                      token: token,
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
