import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:katze/core/services/deep_link_service.dart';
import 'package:katze/core/services/notification_service.dart';
import 'package:katze/di/injection_container.dart' as di;
import 'package:katze/presentation/bloc/game/game_bloc.dart';
import 'package:katze/presentation/bloc/notification/notification_bloc.dart';
import 'package:katze/presentation/bloc/theme/theme_bloc.dart';
import 'package:katze/presentation/pages/game_page.dart';
import 'package:katze/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Initialize services
  final deepLinkService = DeepLinkService();
  final notificationService = NotificationService();

  await Future.wait([
    deepLinkService.initialize(),
    notificationService.initialize(),
  ]);

  runApp(const CatGameApp());
}

class CatGameApp extends StatelessWidget {
  const CatGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameBloc>(
          create: (context) => di.sl<GameBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => di.sl<NotificationBloc>(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            navigatorKey: DeepLinkService().navigationKey,
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
            theme: themeState.themeData,
            initialRoute: '/',
            routes: {
              '/': (context) => const LoginPage(),
              '/game': (context) {
                final gameId =
                    ModalRoute.of(context)?.settings.arguments as String?;
                return const GamePage();
              },
            },
          );
        },
      ),
    );
  }
}
