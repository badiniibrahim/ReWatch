import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_scaffold.dart';
import '../../../../core/services/tmdb_service.dart';

class TmdbSearchView extends StatefulWidget {
  const TmdbSearchView({super.key});

  @override
  State<TmdbSearchView> createState() => _TmdbSearchViewState();
}

class _TmdbSearchViewState extends State<TmdbSearchView> {
  final TmdbService _tmdbService = TmdbService();
  final TextEditingController _searchController = TextEditingController();
  final RxList<TmdbResult> _searchResults = <TmdbResult>[].obs;
  final RxBool _isSearching = false.obs;
  final RxBool _hasSearched = false.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    _isSearching.value = true;
    _hasSearched.value = true;
    _searchResults.value = await _tmdbService.search(query);
    _isSearching.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kSurface,
      appBar: AppBar(
        title: Text(
          'watch_tmdbSearchTitle'.tr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextPrimary,
          ),
        ),
        backgroundColor: AppColors.kSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.kTextPrimary),
      ),
      body: Column(
        children: [
          // Barre de recherche avec design premium
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.kSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.kSurfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.kBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: AppColors.kBackground,
                        fontSize: 16,
                      ),
                      cursorColor: AppColors.kPrimary,
                      decoration: InputDecoration(
                        hintText: 'watch_tmdbSearchPlaceholder'.tr,
                        hintStyle: const TextStyle(color: AppColors.kTextSecondary),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.kPrimary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: _performSearch,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.kPrimary, Color(0xFF9D6CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kPrimary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _performSearch(_searchController.text),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Résultats
          Expanded(
            child: Obx(() {
              if (_isSearching.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.kPrimary),
                );
              }

              if (!_hasSearched.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.movie_filter,
                          size: 64,
                          color: AppColors.kPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'watch_tmdbSearchEmpty'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'watch_tmdbSearchEmptyHint'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.kTextSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'watch_tmdbNoResults'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'watch_tmdbNoResultsHint'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return _buildResultCard(result);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(TmdbResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.back(result: result),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: result.posterUrl != null
                      ? Image.network(
                          result.posterUrl!,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(width: 16),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        result.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Type + Année
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: result.type == 'tv'
                                  ? AppColors.kTypeSeries.withValues(alpha: 0.2)
                                  : AppColors.kTypeMovie.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              result.type == 'tv' ? 'watch_typeSeries'.tr : 'watch_typeMovie'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: result.type == 'tv'
                                    ? AppColors.kTypeSeries
                                    : AppColors.kTypeMovie,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (result.releaseDate != null)
                            Text(
                              result.releaseDate!.substring(0, 4),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.kTextSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Synopsis
                      Text(
                        result.overview.isEmpty
                            ? 'watch_tmdbNoDescription'.tr
                            : result.overview,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.kTextSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Icône de sélection
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.kTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.movie, size: 32, color: AppColors.kTextSecondary),
    );
  }
}
