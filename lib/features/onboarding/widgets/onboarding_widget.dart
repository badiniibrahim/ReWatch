import 'package:flutter/material.dart';

class OnboardingWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title),
    );
  }
}
