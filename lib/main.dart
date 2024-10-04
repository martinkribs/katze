import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Dependency Injection
import 'package:katze/di/injection_container.dart' as di;
import 'package:katze/presentation/bloc/theme/theme_bloc.dart';
import 'package:katze/presentation/pages/home_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize Dependency Injection
  tz.initializeTimeZones(); // Initialize TimeZones

  runApp(
    BlocProvider<ThemeBloc>(
      create: (context) => di.sl<ThemeBloc>(),
      child: const Katze(),
    ),
  );
}

class Katze extends StatelessWidget {
  const Katze({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Katze',
          theme: state.themeData,
          home: const HomePage(),
        );
      },
    );
  }
}