import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service pour détecter la plateforme actuelle.
///
/// Permet de déterminer si l'application tourne sur iOS, Android, ou une autre plateforme.
/// Utile pour adapter l'UI selon le design system (Cupertino vs Material).
class PlatformService {
  PlatformService._();

  /// Vérifie si l'application tourne sur iOS.
  ///
  /// Retourne `true` si la plateforme est iOS, `false` sinon.
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Vérifie si l'application tourne sur Android.
  ///
  /// Retourne `true` si la plateforme est Android, `false` sinon.
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Vérifie si l'application tourne sur macOS.
  ///
  /// Retourne `true` si la plateforme est macOS, `false` sinon.
  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  /// Vérifie si l'application tourne sur le web.
  ///
  /// Retourne `true` si la plateforme est web, `false` sinon.
  static bool get isWeb => kIsWeb;

  /// Retourne le nom de la plateforme actuelle.
  ///
  /// Retourne 'iOS', 'Android', 'macOS', 'Web', ou 'Unknown'.
  static String get platformName {
    if (isWeb) return 'Web';
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (isMacOS) return 'macOS';
    return 'Unknown';
  }
}

