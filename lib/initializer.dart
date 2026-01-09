import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:rewatch/firebase_options.dart';
//import '../firebase_options.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/iauth_repository.dart';

class Initializer {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
    }

    await GetStorage.init();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await _initDependencies();

  }

  static Future<void> _initDependencies() async {
    try {
      if (kDebugMode) {
        debugPrint('🔧 Initializer: Starting dependencies initialization...');
      }

      if (kDebugMode) {
        debugPrint('🔧 Initializer: Registering repositories...');
      }
      Get.put<IAuthRepository>(
        AuthRepository(
          firebaseAuth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
        ),
        permanent: true,
      );

      
    } catch (err) {
      if (kDebugMode) {
        debugPrint('❌ Initializer: Dependencies initialization failed: $err');
      }
      throw Exception('Dependencies initialization failed: $err');
    }
  }
  
}
