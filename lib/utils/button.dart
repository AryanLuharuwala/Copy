import 'package:flutter/material.dart';

class SimpleRoundButton extends StatelessWidget {
  final Color backgroundColor;
  final Widget buttonText;
  final VoidCallback onPressed;

  const SimpleRoundButton({
    super.key,
    required this.backgroundColor,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 12), // Padding for the button
      ),
      child: buttonText,
    );
  }
}
