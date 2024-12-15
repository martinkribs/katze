import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/pages/verification_required_page.dart';
import 'package:katze/presentation/pages/login_page.dart';
import 'package:katze/presentation/providers/theme_provider.dart';
import 'package:katze/presentation/widgets/app_logo.dart';
import 'package:katze/presentation/widgets/auth_form_field.dart';
import 'package:katze/presentation/widgets/loading_button.dart';

class RegistrationState extends ChangeNotifier {
  final AuthService _authService;
  bool isLoading = false;
  String? errorMessage;

  RegistrationState(this._authService);

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistrationState(context.read<AuthService>()),
      child: const _RegistrationView(),
    );
  }
}

class _RegistrationView extends StatefulWidget {
  const _RegistrationView();

  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<_RegistrationView> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<RegistrationState>();
    final result = await state.register(
      name: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (result != null && mounted) {
      // Wait a moment to ensure token is saved
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const VerificationRequiredPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RegistrationState>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 120),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 30),
                AuthFormField(
                  controller: _usernameController,
                  labelText: 'Username',
                  prefixIcon: Icons.person,
                  validator: AuthFormField.usernameValidator,
                ),
                const SizedBox(height: 20),
                AuthFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthFormField.emailValidator,
                ),
                const SizedBox(height: 20),
                AuthFormField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: AuthFormField.passwordValidator,
                ),
                const SizedBox(height: 20),
                AuthFormField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  confirmPasswordText: _passwordController.text,
                ),
                const SizedBox(height: 30),
                LoadingButton(
                  isLoading: state.isLoading,
                  onPressed: _register,
                  child: const Text('Register'),
                ),
                const SizedBox(height: 20),
                LoadingButton.text(
                  isLoading: false,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
