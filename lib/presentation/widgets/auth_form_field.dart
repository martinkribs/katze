import 'package:flutter/material.dart';

class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final String? confirmPasswordText;
  final String? helperText;

  const AuthFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.confirmPasswordText,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        helperText: helperText,
      ),
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: validator ?? (isPassword && confirmPasswordText != null 
          ? (value) => confirmPasswordValidator(value, confirmPasswordText!)
          : null),
    );
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? strongPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]')
        .hasMatch(value)) {
      return 'Password must include letters, numbers, and symbols';
    }
    return null;
  }

  static String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  static String? confirmPasswordValidator(String? value, String originalPassword) {
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
