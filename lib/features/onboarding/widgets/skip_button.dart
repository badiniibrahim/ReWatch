import 'package:flutter/material.dart';

class SkipButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const SkipButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.06,
      right: MediaQuery.of(context).size.width * 0.05,
      child: GestureDetector(
        onTap: onTap,
        child: Text(text),
      ),
    );
  }
}
