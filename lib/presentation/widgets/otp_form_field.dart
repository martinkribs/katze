import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const OtpFormField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'OTP Code',
        prefixIcon: Icon(Icons.lock_clock),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: validator ?? defaultValidator,
    );
  }

  static String? defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP code';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }
}
