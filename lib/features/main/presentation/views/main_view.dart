import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../../../core/widgets/adaptive_widgets.dart';

import '../../../watch/presentation/views/watch_home_view.dart';
import '../../../profile/views/profile_view.dart';
import '../../../../core/config/app_colors.dart';

import '../../../explore/presentation/views/explore_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  static List<Widget> get pages => [
    const WatchHomeView(),
    const ExploreView(),
    const ProfileView(),
  ];

  static const List<AppBottomNavigationItem> navigationItems = [
    AppBottomNavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      labelKey: 'nav_home',
      route: '/home',
    ),
    AppBottomNavigationItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      labelKey: 'nav_explore',
      route: '/explore',
    ),
    AppBottomNavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      labelKey: 'nav_profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AdaptiveScaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: AdaptiveBottomNavigation(
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.changeTab(index),
          items: navigationItems,
        ),
      ),
    );
  }
}
