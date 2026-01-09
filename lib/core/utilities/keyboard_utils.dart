import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utilitaires pour gérer le clavier.
/// 
/// Fournit des méthodes pour fermer le clavier de manière cohérente
/// dans toute l'application.
class KeyboardUtils {
  KeyboardUtils._();

  /// Ferme le clavier si ouvert.
  /// 
  /// Utilise le context GetX ou le context Flutter standard.
  static void unfocus([BuildContext? context]) {
    try {
      if (context != null) {
        FocusScope.of(context).unfocus();
      } else {
        // Utiliser Get.focusScope si disponible
        Get.focusScope?.unfocus();
      }
    } catch (e) {
      // Ignorer les erreurs si le context n'est pas disponible
    }
  }

  /// Ferme le clavier et navigue en arrière.
  /// 
  /// Utile pour éviter que le clavier s'affiche après la navigation.
  /// 
  /// [context] : Le context Flutter (optionnel)
  /// [result] : Résultat à retourner lors de la navigation (optionnel)
  static void unfocusAndBack([BuildContext? context, dynamic result]) {
    unfocus(context);
    if (result != null) {
      Get.back(result: result);
    } else {
      Get.back();
    }
  }
}

