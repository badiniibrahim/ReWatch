import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Helper pour afficher les logos des plateformes de streaming via Assets
class PlatformLogoHelper {
  PlatformLogoHelper._();

  static const Map<String, String> _platformAssets = {
    'netflix': 'assets/images/logo_netflix.png',
    'disney+': 'assets/images/disneyplus.png',
    'amazon prime video': 'assets/images/amazon-prime-video.png',
    'prime video': 'assets/images/amazon-prime-video.png',
    'apple tv+': 'assets/images/apple-tv-plus.jpg',
    'apple tv': 'assets/images/apple-tv-plus.jpg',
    'hbo max': 'assets/images/hbo-max.png',
    'hulu': 'assets/images/hulu.png',
    'canal+': 'assets/images/canal-logo.png',
    'mycanal': 'assets/images/canal-logo.png',
    'paramount+': 'assets/images/paramount-logo.png',
    'youtube': 'assets/images/youtube-logo.png',
    'crunchyroll': 'assets/images/crunchyroll.png',
  };

  /// Retourne le widget logo pour une plateforme donnée
  static Widget getLogo(String platform, {double size = 32}) {
    final platformKey = platform.toLowerCase();

    // Si la plateforme a un logo asset
    if (_platformAssets.containsKey(platformKey)) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            size * 0.2,
          ), // Rounded corners proportional to size
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.2),
          child: Image.asset(
            _platformAssets[platformKey]!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon(platformKey, size);
            },
          ),
        ),
      );
    }

    // Fallback pour "Autre..." ou non reconnu
    return _buildFallbackIcon(platformKey, size);
  }

  static Widget _buildFallbackIcon(String platform, double size) {
    // Cas spécial pour l'option "Autre..." dans les listes
    if (platform == 'autre...') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.kSurfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Icon(
          Icons.add,
          size: size * 0.6,
          color: AppColors.kTextSecondary,
        ),
      );
    }

    // Défaut générique
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          platform.isNotEmpty ? platform[0].toUpperCase() : '?',
          style: TextStyle(
            color: AppColors.kTextSecondary,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
