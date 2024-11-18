import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/pages/games_overview_page.dart';

class VerificationState extends ChangeNotifier {
  final AuthService _authService;
  bool isLoading = false;
  String? errorMessage;
  String? email;
  String code = '';
  String? codeError;

  VerificationState(this._authService) {
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    email = await _authService.getCurrentUserEmail();
    notifyListeners();
  }

  void setCode(String value) {
    code = value;
    validateCode();
    notifyListeners();
  }

  bool validateCode() {
    if (code.isEmpty) {
      codeError = 'Code is required';
      notifyListeners();
      return false;
    }
    if (code.length != 6) {
      codeError = 'Code must be exactly 6 characters';
      notifyListeners();
      return false;
    }
    codeError = null;
    notifyListeners();
    return true;
  }

  Future<void> verifyEmail(BuildContext context) async {
    if (!validateCode()) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final verified = await _authService.verifyEmail(code);
      if (verified && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GamesOverviewPage(),
          ),
        );
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerification(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.resendVerificationNotification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class VerificationRequiredPage extends StatelessWidget {
  const VerificationRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VerificationState(context.read<AuthService>()),
      child: const _VerificationRequiredView(),
    );
  }
}

class _VerificationRequiredView extends StatelessWidget {
  const _VerificationRequiredView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VerificationState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification Required'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread,
                size: 64,
                color: Color(0xFFE7D49E),
              ),
              const SizedBox(height: 24),
              Text(
                'Email Verification Required',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (state.email != null)
                Text(
                  'We sent a verification code to:\n${state.email}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  hintText: 'Enter 6-digit code',
                  errorText: state.codeError,
                  border: const OutlineInputBorder(),
                ),
                maxLength: 6,
                onChanged: state.setCode,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              if (state.errorMessage != null)
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              if (state.isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => state.verifyEmail(context),
                      child: const Text('Verify Email'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => state.resendVerification(context),
                      child: const Text('Resend Verification Code'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
