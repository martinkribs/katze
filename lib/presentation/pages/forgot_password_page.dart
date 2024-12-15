import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/pages/otp_verification_page.dart';
import 'package:katze/presentation/widgets/app_logo.dart';
import 'package:katze/presentation/widgets/auth_form_field.dart';
import 'package:katze/presentation/widgets/loading_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.forgotPassword(_emailController.text.trim());
      
      if (mounted) {
        // Navigate to OTP verification page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Only show error if it's a server error (500)
        if (e.toString().contains('500')) {
          setState(() {
            _errorMessage = e.toString();
            _isLoading = false;
          });
        } else {
          // For other errors, still proceed to OTP page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
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
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthFormField.emailValidator,
                ),
                const SizedBox(height: 30),
                LoadingButton(
                  isLoading: _isLoading,
                  onPressed: _submitForgotPassword,
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
