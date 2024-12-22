import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool elevated;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.style,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = elevated
        ? ElevatedButton(
            style: style,
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(),
          )
        : TextButton(
            style: style,
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(),
          );

    return button;
  }

  Widget _buildChild() {
    return isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : child;
  }

  factory LoadingButton.text({
    Key? key,
    required bool isLoading,
    required VoidCallback onPressed,
    required Widget child,
    ButtonStyle? style,
  }) {
    return LoadingButton(
      key: key,
      isLoading: isLoading,
      onPressed: onPressed,
      style: style,
      elevated: false,
      child: child,
    );
  }
}
