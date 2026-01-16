import 'package:get/get.dart';
import '../../../../core/services/tmdb_service.dart';
import '../../../../core/services/ai_recommendation_service.dart';

class ExploreController extends GetxController {
  final TmdbService _tmdbService = Get.find<TmdbService>();
  final AiRecommendationService _aiService =
      Get.find<AiRecommendationService>();

  final RxList<TmdbResult> trendingItems = <TmdbResult>[].obs;
  final RxList<TmdbResult> nowPlayingItems = <TmdbResult>[].obs;
  final RxList<TmdbResult> aiResults = <TmdbResult>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isAiLoading = false.obs;

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

  Future<void> getAiRecommendations(String mood) async {
    if (mood.trim().isEmpty) return;

    isAiLoading.value = true;
    aiResults.clear();

    try {
      final results = await _aiService.getRecommendations(mood);
      aiResults.value = results;
    } catch (e) {
      print('Error getting AI recommendations: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les recommandations',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAiLoading.value = false;
    }
  }

  void openDetails(TmdbResult result) {
    Get.toNamed('/watch/add', arguments: result);
  }
}
