import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';
import '../services/platform_service.dart';
import 'app_bottom_navigation.dart';

/// Bottom navigation bar adaptatif qui utilise CupertinoTabBar sur iOS et AppBottomNavigation sur Android.
///
/// Ce widget détecte automatiquement la plateforme et utilise le design system
/// approprié pour une expérience native sur chaque plateforme.
class AdaptiveBottomNavigation extends StatelessWidget {
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

  const AdaptiveBottomNavigation({
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
    if (PlatformService.isIOS) {
      // Sur iOS, utiliser CupertinoTabBar
      // Note: CupertinoTabBar nécessite BottomNavigationBarItem
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.kCard,
          border: Border(
            top: BorderSide(
              color: AppColors.kBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: CupertinoTabBar(
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: Colors.transparent,
            activeColor: selectedColor ?? AppColors.kPrimarySolid,
            inactiveColor: unselectedColor ?? AppColors.kTextSecondary,
            items: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;
              
              return BottomNavigationBarItem(
                icon: Icon(isSelected ? item.activeIcon : item.icon),
                label: item.labelKey.tr,
              );
            }).toList(),
          ),
        ),
      );
    }

    // Sur Android, utiliser AppBottomNavigation (Material Design)
    return AppBottomNavigation(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      unselectedColor: unselectedColor,
    );
  }
}

