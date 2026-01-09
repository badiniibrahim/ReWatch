import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TmdbService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String? _apiKey = dotenv.env['API_KEY_TMDB'];
  final String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  TmdbService() {
    if (_apiKey == null) {
      throw Exception('API_KEY_TMDB manquant dans .env');
    }
    _dio.options.queryParameters = {
      'api_key': _apiKey,
      'language': 'fr-FR', // Préférer le français
    };
  }

  /// Recherche films et séries
  /// Retourne une liste de résultats bruts simplifiés
  Future<List<TmdbResult>> search(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get(
        '$_baseUrl/search/multi',
        queryParameters: {'query': query, 'include_adult': false},
      );

      final results = (response.data['results'] as List)
          .where(
            (item) =>
                item['media_type'] == 'movie' || item['media_type'] == 'tv',
          )
          .map((item) => TmdbResult.fromJson(item, _imageBaseUrl))
          .toList();

      return results;
    } catch (e) {
      print('Erreur TMDB Search: $e');
      return [];
    }
  }
}

class TmdbResult {
  final int id;
  final String title;
  final String overview;
  final String? posterUrl;
  final String type; // 'movie' or 'tv'
  final String? releaseDate;

  TmdbResult({
    required this.id,
    required this.title,
    required this.overview,
    this.posterUrl,
    required this.type,
    this.releaseDate,
  });

  factory TmdbResult.fromJson(Map<String, dynamic> json, String imageBaseUrl) {
    return TmdbResult(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'Titre inconnu',
      overview: json['overview'] ?? '',
      posterUrl: json['poster_path'] != null
          ? '$imageBaseUrl${json['poster_path']}'
          : null,
      type: json['media_type'] ?? 'movie',
      releaseDate: json['release_date'] ?? json['first_air_date'],
    );
  }
}
