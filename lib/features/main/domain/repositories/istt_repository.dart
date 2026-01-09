import '../../../../core/result.dart';

/// Interface du repository pour la transcription vocale (Speech-to-Text).
/// 
/// Cette interface définit les opérations pour transcrire l'audio
/// en texte en utilisant Whisper.cpp, Vosk ou Leopard localement.
abstract class ISTTRepository {
  /// Transcrit un fichier audio en texte.
  /// 
  /// [audioPath] : Chemin du fichier audio WAV 16kHz mono
  /// 
  /// Retourne un [Result<String>] avec la transcription textuelle.
  /// 
  /// Retourne un [Failure] si :
  /// - Le fichier audio est invalide
  /// - La transcription échoue
  Future<Result<String>> transcribeAudio(String audioPath);
}

