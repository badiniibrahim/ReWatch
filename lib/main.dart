import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'initializer.dart';
import 'routes/app_pages.dart';

/// Point d'entrée principal de l'application.
///
/// Initialise tous les services nécessaires et lance l'application
/// avec la route initiale déterminée par `Routes.initial`.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration de l'orientation (portrait uniquement pour cette app)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style de la barre de statut (Transparent pour design immersif)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.light, // Icônes claires par défaut (Dark Mode)
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );

  // Initialisation des services (Firebase, Storage, etc.)
  await Initializer.init();

  // Détermination de la route initiale (Splash Screen)
  const initialRoute = Routes.splash;

  // Lancement de l'application
  runApp(App(initialRoute: initialRoute));
}
