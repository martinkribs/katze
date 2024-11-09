import 'package:flutter/material.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/di/injection_container.dart';
import 'package:katze/presentation/pages/games_overview_page.dart';

class VerificationRequiredPage extends StatefulWidget {
  const VerificationRequiredPage({Key? key}) : super(key: key);

  @override
  _VerificationRequiredPageState createState() =>
      _VerificationRequiredPageState();
}

class _VerificationRequiredPageState extends State<VerificationRequiredPage> {
  final _authService = sl<AuthService>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await _authService.getCurrentUserEmail();
    setState(() {
      _email = email;
    });
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.getCurrentUser();
      // If we get user data without error, user is verified
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const GamesOverviewPage(),
        ),
      );
    } catch (e) {
      final errorMessage = e.toString();
      if (!errorMessage.contains('verified')) {
        // If error is not about verification, user might be verified
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GamesOverviewPage(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Email not yet verified. Please check your email.';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.resendVerificationNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (_email != null)
                Text(
                  'We sent a verification email to:\n$_email',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _checkVerificationStatus,
                      child: const Text('I have verified my email'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _resendVerification,
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
