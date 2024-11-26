import 'package:flutter/material.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/pages/games_overview_page.dart';
import 'package:katze/presentation/pages/login_page.dart';
import 'package:katze/presentation/pages/verification_required_page.dart';
import 'package:provider/provider.dart';

class AuthStateManager extends ChangeNotifier {
  final AuthService _authService;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  Widget? _initialRoute;

  AuthStateManager(this._authService);

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Widget get initialRoute => _initialRoute ?? const LoginPage();

  Future<void> initializeAuth() async {
    try {
      final hasToken = await _authService.isLoggedIn();
      if (!hasToken) {
        _initialRoute = const LoginPage();
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Verify token validity by getting current user
      try {
        await _authService.getCurrentUser();
        _initialRoute = const GamesOverviewPage();
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        if (e.toString().contains('verified')) {
          _initialRoute = const VerificationRequiredPage();
        } else {
          // Token invalid or expired
          await _authService.logout(); // Clear invalid token
          _initialRoute = const LoginPage();
        }
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _initialRoute = const LoginPage();
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add method to handle logout
  Future<void> handleLogout() async {
    await _authService.logout();
    _isInitialized = false;
    await initializeAuth();
  }
}

// Splash screen widget to handle initial auth check
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authStateManager = context.read<AuthStateManager>();
      if (!authStateManager.isInitialized) {
        authStateManager.initializeAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStateManager = context.watch<AuthStateManager>();

    if (authStateManager.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return authStateManager.initialRoute;
  }
}
