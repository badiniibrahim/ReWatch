import 'package:get/get.dart';
import '../../../../core/services/tmdb_service.dart';

class ExploreController extends GetxController {
  final TmdbService _tmdbService = Get.find<TmdbService>();

  final RxList<TmdbResult> trendingItems = <TmdbResult>[].obs;
  final RxList<TmdbResult> nowPlayingItems = <TmdbResult>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final trending = await _tmdbService.getTrending();
      final nowPlaying = await _tmdbService.getNowPlayingMovies();

      trendingItems.value = trending;
      nowPlayingItems.value = nowPlaying;
    } catch (e) {
      print('Error loading explore data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openDetails(TmdbResult result) {
    // Navigate to a details preview page or directly to Add form with pre-filled data
    // For now, let's open the Add form with pre-filled data using a specific route/arg
    // Or we could have an "Explore Details" view.
    // The user wants to ADD it to their list potentially.
    // So usually clicking opens a "Movie Sheet" which has an "Add to Watchlist" button.

    // For simplicity, let's go to WatchAddView with the TMDB ID or item to prefill.
    // Assuming WatchAddView can take an item or we pass it.
    // But WatchAddView is designed to SEARCH.
    // Maybe we just want to show a bottom sheet "Add this?"

    // Let's defer this specific flow. We will just print for now or navigate to Add.
    Get.toNamed('/watch/add', arguments: result);
    // We will need to update WatchItemFormController to handle `TmdbResult` argument if we do this.
  }
}
