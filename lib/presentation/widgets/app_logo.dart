import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final EdgeInsets padding;

  const AppLogo({
    super.key,
    this.size = 150,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      child: Image.asset(
        'assets/icon/katze.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
