import '../../../../core/result.dart';

/// Interface du repository pour les opérations audio.
/// 
/// Cette interface définit les opérations pour extraire l'audio
/// d'une vidéo et le convertir au format requis pour la transcription.
abstract class IAudioRepository {
  /// Extrait l'audio d'un fichier vidéo et le convertit en WAV 16kHz mono.
  /// 
  /// [videoPath] : Chemin du fichier vidéo
  /// 
  /// Retourne un [Result<String>] avec le chemin du fichier audio extrait.
  /// Le fichier audio est temporaire et doit être supprimé après utilisation.
  Future<Result<String>> extractAudioToWav(String videoPath);
  
  /// Supprime un fichier audio temporaire.
  /// 
  /// [audioPath] : Chemin du fichier à supprimer
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si la suppression réussit
  /// - [Failure] si le fichier n'existe pas ou ne peut pas être supprimé
  Future<Result<void>> deleteAudioFile(String audioPath);
}

