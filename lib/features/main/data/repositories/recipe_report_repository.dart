import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/result.dart';
import '../../domain/entities/recipe_report.dart';
import '../../domain/repositories/irecipe_report_repository.dart';

/// Implémentation du repository pour les signalements de recettes utilisant Firestore.
/// 
/// Toutes les opérations sont sécurisées par les Security Rules Firestore
/// qui vérifient que l'utilisateur ne peut accéder qu'à ses propres signalements.
/// 
/// Exemple :
/// ```dart
/// final repository = RecipeReportRepository(
///   firestore: FirebaseFirestore.instance,
///   auth: FirebaseAuth.instance,
/// );
/// ```
class RecipeReportRepository implements IRecipeReportRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _collectionName = 'recipeReports';
  
  /// Crée une nouvelle instance du repository.
  /// 
  /// [firestore] : Instance Firestore pour les opérations de base de données
  /// [auth] : Instance Firebase Auth pour l'authentification
  RecipeReportRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;
  
  @override
  Future<Result<void>> saveReport(RecipeReport report) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != report.userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      // Générer un ID si non fourni
      final reportId = report.id.isEmpty 
          ? _firestore.collection(_collectionName).doc().id
          : report.id;
      
      // Créer le document avec l'ID
      final reportData = report.copyWith(id: reportId).toMap();
      
      // Convertir createdAt en Timestamp Firestore
      reportData['createdAt'] = Timestamp.fromDate(report.createdAt);
      
      // Sauvegarder dans Firestore
      await _firestore
          .collection(_collectionName)
          .doc(reportId)
          .set(reportData, SetOptions(merge: false));
      
      if (kDebugMode) {
        debugPrint('✅ Recipe report saved: $reportId');
      }
      
      return const Success(null);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException saving report: ${e.code} - ${e.message}');
      }
      
      String errorMessage = 'Erreur lors de la sauvegarde du signalement';
      
      if (e.code == 'permission-denied') {
        errorMessage = 'Permission refusée. Vérifiez les règles Firestore.';
      } else if (e.code == 'unavailable') {
        errorMessage = 'Service temporairement indisponible';
      }
      
      return Failure(
        errorMessage,
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error saving report: $e');
      }
      
      return Failure(
        'Erreur inattendue lors de la sauvegarde du signalement',
        errorCode: 'unexpected-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<List<RecipeReport>>> getReportsByRecipeId(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('recipeId', isEqualTo: recipeId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final reports = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Convertir Timestamp Firestore en DateTime
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return RecipeReport.fromMap(data);
      }).toList();
      
      return Success(reports);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException getting reports: ${e.code} - ${e.message}');
      }
      
      return Failure(
        'Erreur lors de la récupération des signalements',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error getting reports: $e');
      }
      
      return Failure(
        'Erreur inattendue lors de la récupération des signalements',
        errorCode: 'unexpected-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<List<RecipeReport>>> getReportsByUserId(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final reports = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Convertir Timestamp Firestore en DateTime
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return RecipeReport.fromMap(data);
      }).toList();
      
      return Success(reports);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException getting user reports: ${e.code} - ${e.message}');
      }
      
      return Failure(
        'Erreur lors de la récupération des signalements',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error getting user reports: $e');
      }
      
      return Failure(
        'Erreur inattendue lors de la récupération des signalements',
        errorCode: 'unexpected-error',
        error: e,
      );
    }
  }
}

