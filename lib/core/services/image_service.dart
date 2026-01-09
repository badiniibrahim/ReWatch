import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Sélectionne une image depuis la galerie
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compression légère
        maxWidth: 1920,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la sélection de l\'image: $e');
      return null;
    }
  }

  /// Upload l'image vers ImageKit via API HTTP
  Future<String?> uploadImage(File file) async {
    try {
      final privateKey = dotenv.env['IMAGE_PRIVATE_KIT_IMAGE'];

      if (privateKey == null) {
        throw Exception('IMAGE_PRIVATE_KIT_IMAGE manquant dans .env');
      }

      final uri = Uri.parse("https://upload.imagekit.io/api/v1/files/upload");
      final request = http.MultipartRequest("POST", uri);

      // Authentication: Basic Base64(privateKey + ":")
      final basicAuth = 'Basic ${base64Encode(utf8.encode('$privateKey:'))}';
      request.headers['Authorization'] = basicAuth;

      // Paramètres
      request.fields['fileName'] =
          'rewatch_${DateTime.now().millisecondsSinceEpoch}.jpg';
      request.fields['useUniqueFileName'] = 'true';
      request.fields['folder'] = 'rewatch_uploads';

      // Fichier
      final multipartFile = await http.MultipartFile.fromPath(
        "file",
        file.path,
      );
      request.files.add(multipartFile);

      // Envoi
      final response = await request.send();
      final responseBytes = await response.stream.toBytes();
      final responseString = utf8.decode(responseBytes);
      final json = jsonDecode(responseString);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json['url'] as String?;
      } else {
        debugPrint('Erreur Upload ImageKit: ${json['message']}');
        throw Exception(json['message'] ?? 'Erreur inconnue lors de l\'upload');
      }
    } catch (e) {
      debugPrint('Exception Upload ImageKit: $e');
      rethrow;
    }
  }
}
