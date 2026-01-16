import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';

/// Item de navigation pour le bottom bar.
///
/// Chaque item représente une page accessible via le bottom navigation.
class AppBottomNavigationItem {
  /// Icône inactive.
  final IconData icon;

  /// Icône active.
  final IconData activeIcon;

  /// Clé de traduction pour le label.
  final String labelKey;

  /// Route associée à cet item.
  final String route;

  /// Badge optionnel (notifications, compteurs, etc.).
  final String? badge;

  const AppBottomNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    required this.route,
    this.badge,
  });
}

/// Widget de navigation bottom bar réutilisable.
///
/// Suit les guidelines Material 3 et utilise les traductions.
class AppBottomNavigation extends StatelessWidget {
  /// Index de l'item actuellement sélectionné.
  final int currentIndex;

  /// Callback appelé lors du tap sur un item.
  final Function(int) onTap;

  /// Liste des items de navigation.
  final List<AppBottomNavigationItem> items;

  /// Couleur de fond optionnelle.
  final Color? backgroundColor;

  /// Couleur de l'item sélectionné.
  final Color? selectedColor;

  /// Couleur des items non sélectionnés.
  final Color? unselectedColor;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ensure the bottom bar background is transparent to show content behind glass
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          height: 70, // Fixed height for consistency
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: (backgroundColor ?? AppColors.kSurface).withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
          ),
          // TODO: Add BackdropFilter for blur if performance allows (often heavy on mobile)
          // For now, opacity handles the see-through feel adequately.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return _buildFloatingNavItem(
                item: item,
                isSelected: isSelected,
                onTap: () => onTap(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required AppBottomNavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final selectedColorValue = selectedColor ?? AppColors.kPrimary;
    final unselectedColorValue = unselectedColor ?? AppColors.kTextSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColorValue.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? selectedColorValue : unselectedColorValue,
              size: 24,
            ),
            // Show label only when selected for a cleaner look (optional, but popular in modern designs)
            // Or keep it simple with just icons if labels are obvious.
            // Let's keep it icon-only or standard.
            // The request asked for "design", implying visual polish.
            // Let's try the "Label expands on selection" style which is very "Wow".
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.labelKey.tr,
                style: TextStyle(
                  color: selectedColorValue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
