import 'package:flutter/material.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/pages/password_reset_page.dart';
import 'package:katze/presentation/widgets/app_logo.dart';
import 'package:katze/presentation/widgets/loading_button.dart';
import 'package:katze/presentation/widgets/otp_form_field.dart';
import 'package:provider/provider.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final resetToken = await authService.verifyOtp(
        email: widget.email,
        otp: _otpController.text.trim(),
      );

      if (mounted) {
        // Navigate to password reset page with reset token
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PasswordResetPage(
              email: widget.email,
              resetToken: resetToken,
            ),
          ),
        );
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
        title: const Text('Verify OTP'),
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
                const SizedBox(height: 20),
                Text(
                  'Enter the 6-digit code sent to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 30),
                OtpFormField(
                  controller: _otpController,
                ),
                const SizedBox(height: 30),
                LoadingButton(
                  isLoading: _isLoading,
                  onPressed: _verifyOtp,
                  child: const Text('Verify OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
