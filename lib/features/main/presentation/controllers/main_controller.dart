import 'package:flutter/foundation.dart';
import 'package:get/get.dart';


class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _updateIndexFromRoute();
  }
  

  void changeTab(int index) {
    if (index != currentIndex.value && index < 3) {
      currentIndex.value = index;
    }
  }

  void _updateIndexFromRoute() {
    final route = Get.currentRoute;
    if (route.isEmpty) return;

    final index = _getIndexForRoute(route);
    if (index != null && index != currentIndex.value) {
      currentIndex.value = index;
    }
  }

  int? _getIndexForRoute(String route) {
    switch (route) {
      case '/home':
      case '/':
        return 0;
      case '/explore':
        return 1;
      case '/profile':
        return 2;
      default:
        return null;
    }
  }
}
