import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katze/di/injection_container.dart' as di;
import 'package:katze/presentation/bloc/game/game_bloc.dart';
import 'package:katze/presentation/bloc/notification/notification_bloc.dart';
import 'package:katze/presentation/bloc/theme/theme_bloc.dart';
import 'package:katze/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

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
            title: 'Cat Game',
            theme: themeState.themeData,
            home: const LoginPage(),
          );
        },
      ),
    );
  }
}
