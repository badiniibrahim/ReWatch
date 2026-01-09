/// Pattern Result<T> pour la gestion d'erreurs typée.
///
/// Utilisé dans toute l'application pour représenter le résultat
/// d'une opération qui peut échouer.
sealed class Result<T> {
  const Result();
}

/// Succès avec données.
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Échec avec message d'erreur.
class Failure<T> extends Result<T> {
  final String message;
  final String? errorCode;
  final Object? error;

  const Failure(this.message, {this.errorCode, this.error});
}

/// Extension pour faciliter l'utilisation de Result<T>.
extension ResultExtension<T> on Result<T> {
  /// Pattern matching pour traiter le résultat.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? errorCode, Object? error)
    failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Failure<T>(:final message, :final errorCode, :final error) => failure(
        message,
        errorCode ?? 'unknown',
        error ?? Object(),
      ),
    };
  }

  /// Vérifie si le résultat est un succès.
  bool get isSuccess => this is Success<T>;

  /// Vérifie si le résultat est un échec.
  bool get isFailure => this is Failure<T>;

  /// Retourne les données ou null.
  T? get dataOrNull =>
      when(success: (data) => data, failure: (_, __, ___) => null);

  /// Retourne l'échec ou null.
  Failure<T>? get failureOrNull => when(
    success: (_) => null,
    failure: (message, errorCode, error) =>
        Failure(message, errorCode: errorCode, error: error),
  );
}
