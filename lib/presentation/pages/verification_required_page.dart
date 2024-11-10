import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/presentation/pages/games_overview_page.dart';

// Erstellen eines VerificationState
class VerificationState extends ChangeNotifier {
  final AuthService _authService;
  bool isLoading = false;
  String? errorMessage;
  String? email;

  VerificationState(this._authService) {
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    email = await _authService.getCurrentUserEmail();
    notifyListeners();
  }

  Future<void> checkVerificationStatus(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.getCurrentUser();
      // Wenn kein Fehler auftritt, ist der User verifiziert
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GamesOverviewPage(),
          ),
        );
      }
    } catch (e) {
      final error = e.toString();
      if (!error.contains('verified')) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const GamesOverviewPage(),
            ),
          );
        }
      } else {
        errorMessage = 'Email not yet verified. Please check your email.';
      }
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
            content: Text('Verification email sent'),
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
                  'We sent a verification email to:\n${state.email}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              const SizedBox(height: 24),
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
                      onPressed: () => state.checkVerificationStatus(context),
                      child: const Text('I have verified my email'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => state.resendVerification(context),
                      child: const Text('Resend Verification Email'),
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