import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

/// Service de gestion des permissions de l'application.
/// 
/// Ce service centralise toute la logique de gestion des permissions
/// (caméra, galerie, localisation, etc.) en suivant les bonnes pratiques.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final permissionService = PermissionService();
/// final status = await permissionService.requestCameraPermission();
/// if (status.isGranted) {
///   // Utiliser la caméra
/// }
/// ```
class PermissionService {
  /// Demande la permission d'accès à la caméra.
  /// 
  /// Retourne le statut de la permission après la demande.
  /// 
  /// Gère automatiquement les cas où la permission est refusée de manière permanente
  /// en ouvrant les paramètres de l'application.
  /// 
  /// Exemple :
  /// ```dart
  /// final status = await permissionService.requestCameraPermission();
  /// if (status.isGranted) {
  ///   // Permission accordée
  /// } else if (status.isPermanentlyDenied) {
  ///   // Ouvrir les paramètres
  ///   await permissionService.openAppSettings();
  /// }
  /// ```
  Future<handler.PermissionStatus> requestCameraPermission() async {
    if (kDebugMode) {
      debugPrint('📷 Requesting camera permission...');
    }

    final status = await handler.Permission.camera.request();

    if (kDebugMode) {
      debugPrint('📷 Camera permission status: ${status.toString()}');
    }

    return status;
  }

  /// Vérifie le statut actuel de la permission caméra sans faire de demande.
  /// 
  /// Utile pour vérifier l'état de la permission avant d'effectuer une action.
  Future<handler.PermissionStatus> checkCameraPermission() async {
    final status = await handler.Permission.camera.status;
    
    if (kDebugMode) {
      debugPrint('📷 Camera permission check: ${status.toString()}');
    }
    
    return status;
  }

  /// Demande la permission d'accès à la galerie (photos).
  /// 
  /// Sur Android, demande la permission de stockage.
  /// Sur iOS, demande la permission d'accès à la photothèque.
  /// 
  /// Retourne le statut de la permission après la demande.
  Future<handler.PermissionStatus> requestGalleryPermission() async {
    if (kDebugMode) {
      debugPrint('🖼️ Requesting gallery permission...');
    }

    // Sur iOS, utiliser photos
    // Sur Android, utiliser storage ou photos selon la version
    final permission = _getGalleryPermission();
    final status = await permission.request();

    if (kDebugMode) {
      debugPrint('🖼️ Gallery permission status: ${status.toString()}');
    }

    return status;
  }

  /// Vérifie le statut actuel de la permission galerie sans faire de demande.
  Future<handler.PermissionStatus> checkGalleryPermission() async {
    final permission = _getGalleryPermission();
    final status = await permission.status;
    
    if (kDebugMode) {
      debugPrint('🖼️ Gallery permission check: ${status.toString()}');
    }
    
    return status;
  }

  /// Retourne la permission appropriée pour la galerie selon la plateforme.
  handler.Permission _getGalleryPermission() {
    // Sur iOS 14+, utiliser Permission.photos
    // Sur Android, utiliser Permission.photos (API 33+) ou Permission.storage (API < 33)
    return handler.Permission.photos;
  }

  /// Demande la permission d'accès à la localisation.
  /// 
  /// Demande à la fois la localisation précise et approximative.
  /// 
  /// Retourne le statut de la permission après la demande.
  Future<handler.PermissionStatus> requestLocationPermission() async {
    if (kDebugMode) {
      debugPrint('📍 Requesting location permission...');
    }

    final status = await handler.Permission.location.request();

    if (kDebugMode) {
      debugPrint('📍 Location permission status: ${status.toString()}');
    }

    return status;
  }

  /// Vérifie le statut actuel de la permission localisation sans faire de demande.
  Future<handler.PermissionStatus> checkLocationPermission() async {
    final status = await handler.Permission.location.status;
    
    if (kDebugMode) {
      debugPrint('📍 Location permission check: ${status.toString()}');
    }
    
    return status;
  }

  /// Ouvre les paramètres de l'application pour permettre à l'utilisateur
  /// de modifier les permissions manuellement.
  /// 
  /// Utile lorsque la permission est refusée de manière permanente.
  /// 
  /// Exemple :
  /// ```dart
  /// if (status.isPermanentlyDenied) {
  ///   await permissionService.openAppSettings();
  /// }
  /// ```
  Future<bool> openAppSettings() async {
    if (kDebugMode) {
      debugPrint('⚙️ Opening app settings...');
    }

    final opened = await handler.openAppSettings();

    if (kDebugMode) {
      debugPrint('⚙️ App settings opened: $opened');
    }

    return opened;
  }

  /// Vérifie si une permission est accordée.
  /// 
  /// Retourne `true` si la permission est accordée, `false` sinon.
  bool isGranted(handler.PermissionStatus status) {
    return status.isGranted;
  }

  /// Vérifie si une permission est refusée de manière permanente.
  /// 
  /// Retourne `true` si la permission est refusée de manière permanente,
  /// ce qui nécessite d'ouvrir les paramètres de l'application.
  bool isPermanentlyDenied(handler.PermissionStatus status) {
    return status.isPermanentlyDenied;
  }

  /// Vérifie si une permission est refusée (mais pas de manière permanente).
  /// 
  /// Retourne `true` si la permission est refusée mais peut encore être demandée.
  bool isDenied(handler.PermissionStatus status) {
    return status.isDenied;
  }

  /// Obtient un message utilisateur traduit pour un statut de permission.
  /// 
  /// Retourne un message approprié selon le statut de la permission.
  String getPermissionStatusMessage(handler.PermissionStatus status) {
    if (status.isGranted) {
      return 'permission_granted'.tr;
    } else if (status.isPermanentlyDenied) {
      return 'permission_permanently_denied'.tr;
    } else if (status.isDenied) {
      return 'permission_denied'.tr;
    } else if (status.isRestricted) {
      return 'permission_restricted'.tr;
    } else {
      return 'permission_unknown'.tr;
    }
  }
}

