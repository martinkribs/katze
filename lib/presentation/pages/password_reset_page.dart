import 'package:flutter/material.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/widgets/app_logo.dart';
import 'package:katze/presentation/widgets/auth_form_field.dart';
import 'package:katze/presentation/widgets/loading_button.dart';
import 'package:provider/provider.dart';

class PasswordResetPage extends StatefulWidget {
  final String email;
  final String resetToken;

  const PasswordResetPage({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.resetPassword(
        email: widget.email,
        password: _passwordController.text,
        resetToken: widget.resetToken,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully')),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 30),
                AuthFormField(
                  controller: _passwordController,
                  labelText: 'New Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: AuthFormField.strongPasswordValidator,
                  helperText: 'At least 8 characters with letters, numbers, and symbols',
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
                  isLoading: _isLoading,
                  onPressed: _resetPassword,
                  child: const Text('Reset Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
