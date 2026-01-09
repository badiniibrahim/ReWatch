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
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.kCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimarySolid.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: _buildNavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required AppBottomNavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final selectedColorValue = selectedColor ?? AppColors.kPrimarySolid;
    final unselectedColorValue = unselectedColor ?? AppColors.kTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColorValue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected
                          ? selectedColorValue
                          : unselectedColorValue,
                      size: 22,
                    ),
                  ),
                  if (item.badge != null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.kError,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.kCard,
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          item.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? selectedColorValue
                      : unselectedColorValue,
                ),
                child: Text(
                  item.labelKey.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
