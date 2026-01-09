import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Helper pour afficher les logos des plateformes de streaming
class PlatformLogoHelper {
  PlatformLogoHelper._();

  /// Retourne le widget logo pour une plateforme donnée
  static Widget getLogo(String platform, {double size = 32}) {
    final platformKey = platform.toLowerCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: _getGradient(platformKey),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: _getColor(platformKey).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: _getIcon(platformKey, size)),
    );
  }

  static LinearGradient _getGradient(String platform) {
    final color = _getColor(platform);
    return LinearGradient(
      colors: [color, color.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color _getColor(String platform) {
    switch (platform) {
      case 'netflix':
        return const Color(0xFFE50914);
      case 'disney+':
        return const Color(0xFF113CCF);
      case 'amazon prime video':
        return const Color(0xFF00A8E1);
      case 'apple tv+':
        return const Color(0xFF000000);
      case 'hbo max':
        return const Color(0xFF7F3FF2);
      case 'hulu':
        return const Color(0xFF1CE783);
      case 'canal+':
        return const Color(0xFF000000);
      case 'paramount+':
        return const Color(0xFF0064FF);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'crunchyroll':
        return const Color(0xFFF47521);
      default:
        return AppColors.kSurfaceVariant;
    }
  }

  static Widget _getIcon(String platform, double size) {
    final iconSize = size * 0.55;
    final textSize = size * 0.35;

    switch (platform) {
      case 'netflix':
        return Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize * 1.2,
            fontWeight: FontWeight.w900,
            fontFamily: 'Arial',
          ),
        );
      case 'disney+':
        return Text(
          'D+',
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'amazon prime video':
        return Icon(Icons.play_arrow, size: iconSize, color: Colors.white);
      case 'apple tv+':
        return Icon(Icons.apple, size: iconSize, color: Colors.white);
      case 'hbo max':
        return Text(
          'HBO',
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize * 0.9,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        );
      case 'hulu':
        return Text(
          'hulu',
          style: TextStyle(
            color: Colors.black,
            fontSize: textSize * 0.85,
            fontWeight: FontWeight.w900,
          ),
        );
      case 'canal+':
        return Text(
          'C+',
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'paramount+':
        return Icon(Icons.star, size: iconSize, color: Colors.white);
      case 'youtube':
        return Icon(Icons.play_arrow, size: iconSize, color: Colors.white);
      case 'crunchyroll':
        return Text(
          'CR',
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'autre...':
        return Icon(
          Icons.add_circle_outline,
          size: iconSize,
          color: AppColors.kTextSecondary,
        );
      default:
        return Icon(
          Icons.play_circle_outline,
          size: iconSize,
          color: AppColors.kTextSecondary,
        );
    }
  }
}
