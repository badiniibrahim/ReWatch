import 'package:flutter/material.dart';

/// Couleurs globales de l'application ReWatch.
///
/// Palette "Cinema Premium" : Dark Mode First, contrastes élevés,
/// accentuation par le Violet Électrique (#7F5AF0).
class AppColors {
  AppColors._();

  // ========== BRAND COLORS ==========
  /// "Electric Iris" - Couleur Signature (Mystère, Créativité, Premium)
  static const Color kPrimary = Color(0xFF7F5AF0);

  /// Version plus foncée pour les états pressés ou les bordures
  static const Color kPrimaryDark = Color(0xFF6246EA);

  /// Version plus claire pour les effets de glow
  static const Color kPrimaryLight = Color(0xFF9E86F5);

  /// Container pour les états sélectionnés (faible opacité)
  static const Color kPrimaryContainer = Color(0xFF2B2640); // Darker purple bg

  // ========== ACCENT COLORS ==========
  /// "Success Green" - Validation, Progression
  static const Color kSuccess = Color(0xFF2CB67D);

  /// "Warning Amber" - Notes moyennes, informations
  static const Color kWarning = Color(0xFFF59E0B); // Amber 500

  /// "Destructive Red" - Suppression, Erreurs
  static const Color kError = Color(0xFFEF4565);

  /// "Info Blue" - Liens, Infos neutres
  static const Color kInfo = Color(0xFF3DA9FC);

  // ========== NEUTRALS (DARK MODE DEFAULT) ==========
  /// Background principal (Noir profond mais pas pur pour éviter le smearing OLED)
  static const Color kBackground = Color(0xFF0A0A0A); // Almost Black

  /// Surfaces (Cards, Sheets, BottomNav)
  static const Color kSurface = Color(0xFF16161A); // Dark Grey

  /// Surfaces élevées (Modals, Popups, Dropdowns)
  static const Color kSurfaceElevated = Color(0xFF242629); // Lighter Grey

  /// Bordures subtiles
  static const Color kBorder = Color(0xFF2D2D2D);
  static const Color kDivider = Color(0xFF2D2D2D);

  // ========== TEXT COLORS ==========
  /// Titres, Textes principaux (Blanc pur)
  static const Color kTextPrimary = Color(0xFFFFFFFE);

  /// Sous-titres, descriptions (Gris froid)
  static const Color kTextSecondary = Color(0xFF94A1B2);

  /// Placeholders, textes désactivés
  static const Color kTextTertiary = Color(0xFF72757E);

  // ========== LIGHT MODE OVERRIDES (Optional usage) ==========
  // Si on utilise le Light Mode, on mappera ces couleurs :
  // Background: #FAFAFA
  // Surface: #FFFFFF
  // TextPrimary: #16161A

  static const Color kLightBackground = Color(0xFFFAFAFA);
  static const Color kLightSurface = Color(0xFFFFFFFF);
  static const Color kLightTextPrimary = Color(0xFF16161A);
  static const Color kLightTextSecondary = Color(0xFF5F6C7B);
  static const Color kLightBorder = Color(0xFFD1D1D1);

  // ========== FUNCTIONAL COLORS ==========
  /// Overlay pour les images (dégradé noir)
  static const Color kOverlayDark = Color(0xAA000000);

  /// Shadow color
  static const Color kShadow = Color(0xFF010101);

  // ========== COMPATIBILITY & SEMANTIC ALIASES ==========
  static const Color kPrimarySolid = kPrimary;

  // Cards maps to Surface in Dark Mode, or Elevatd Surface
  static const Color kCard = kSurfaceElevated;
  static const Color kCardSecondary =
      kSurface; // Slightly darker/lighter depending on need

  // Inputs
  static const Color kInput = kSurfaceElevated; // Background of inputs
  static const Color kRing = kPrimary; // Focus ring
  static const Color kBorderHover = kPrimaryLight;

  // Variants from old theme mapped to new
  static const Color kSurfaceVariant = kSurfaceElevated;
  static const Color kErrorContainer = Color(0xFF5A1D2D); // Dark Red background
  static const Color kSurfaceOverlay = kSurfaceElevated;

  // Status & Types (Restoring for compatibility)
  static const Color kTypeMovie = Color(0xFF8B5CF6);
  static const Color kTypeSeries = Color(0xFF6366F1);

  static const Color kStatusWatching = kInfo;
  static const Color kStatusCompleted = kSuccess;
  static const Color kStatusPlanned = kWarning;

  // ========== STATS GRADIENT ==========
  static const Color kStatsGradientStart = Color(0xFF1A1A2E);
  static const Color kStatsGradientEnd = Color(0xFF16213E);
}
