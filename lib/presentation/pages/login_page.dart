import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:katze/presentation/providers/theme_provider.dart';
import 'package:katze/presentation/widgets/app_logo.dart';
import 'package:katze/presentation/widgets/auth_form_field.dart';
import 'package:katze/presentation/widgets/loading_button.dart';
import 'package:provider/provider.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/pages/games_overview_page.dart';
import 'package:katze/presentation/pages/registration_page.dart';
import 'package:katze/presentation/pages/verification_required_page.dart';
import 'package:katze/presentation/pages/forgot_password_page.dart';

class LoginState extends ChangeNotifier {
  final AuthService _authService;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  LoginState(this._authService);

  // Getters
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  GlobalKey<FormState> get formKey => _formKey;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _extractErrorMessage(String error) {
    try {
      final Map<String, dynamic> errorJson = json.decode(error);
      return errorJson['message'] ?? error;
    } catch (e) {
      return error.replaceAll('Exception: ', '');
    }
  }

  Future<void> login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      try {
        await _authService.getCurrentUser();
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const GamesOverviewPage(),
            ),
          );
        }
      } catch (e) {
        final errorMessage = _extractErrorMessage(e.toString());
        if (errorMessage.contains('verified')) {
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const VerificationRequiredPage(),
              ),
            );
          }
        } else {
          _errorMessage = errorMessage;
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginState(context.read<AuthService>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final loginState = context.watch<LoginState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: loginState.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(),
                if (loginState.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    loginState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 30),
                AuthFormField(
                  controller: loginState.emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthFormField.emailValidator,
                ),
                const SizedBox(height: 20),
                AuthFormField(
                  controller: loginState.passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: AuthFormField.passwordValidator,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 30),
                LoadingButton(
                  isLoading: loginState.isLoading,
                  onPressed: () => loginState.login(context),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),
                LoadingButton.text(
                  isLoading: false,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegistrationPage(),
                      ),
                    );
                  },
                  child: const Text('Create an Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
