import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/platform_service.dart';

/// Scaffold adaptatif qui utilise CupertinoPageScaffold sur iOS et Scaffold sur Android.
///
/// Ce widget détecte automatiquement la plateforme et utilise le design system
/// approprié pour une expérience native sur chaque plateforme.
class AdaptiveScaffold extends StatelessWidget {
  /// Titre de l'AppBar (iOS) ou titre de la page.
  final String? title;

  /// Widget personnalisé pour l'AppBar (Material uniquement).
  final PreferredSizeWidget? appBar;

  /// Widget personnalisé pour la navigation bar (iOS uniquement).
  final ObstructingPreferredSizeWidget? navigationBar;

  /// Corps de la page.
  final Widget body;

  /// Couleur de fond.
  final Color? backgroundColor;

  /// Indique si le SafeArea doit être utilisé.
  final bool useSafeArea;

  /// Widget flottant (FAB) pour Material uniquement.
  final Widget? floatingActionButton;

  /// Position du FAB.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Indique si le body doit être dans un resizeToAvoidBottomInset.
  final bool resizeToAvoidBottomInset;

  /// Bottom navigation bar adaptatif.
  final Widget? bottomNavigationBar;

  const AdaptiveScaffold({
    super.key,
    this.title,
    this.appBar,
    this.navigationBar,
    required this.body,
    this.backgroundColor,
    this.useSafeArea = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.kSurface;

    if (PlatformService.isIOS) {
      // Sur iOS, si on a un bottomNavigationBar, on doit l'intégrer dans le body
      if (bottomNavigationBar != null) {
        return CupertinoPageScaffold(
          backgroundColor: effectiveBackgroundColor,
          navigationBar:
              navigationBar ??
              (title != null
                  ? CupertinoNavigationBar(
                      middle: Text(
                        title!,
                        style: TextStyle(
                          color: AppColors.kTextPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.kCard,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.kBorder,
                          width: 0.5,
                        ),
                      ),
                    )
                  : null),
          child: Column(
            children: [
              Expanded(
                child: useSafeArea
                    ? SafeArea(child: body, bottom: false)
                    : body,
              ),
              bottomNavigationBar!,
            ],
          ),
        );
      }

      // Sans bottomNavigationBar, comportement normal
      Widget content = useSafeArea ? SafeArea(child: body) : body;

      // Ajout du FAB sur iOS via Stack
      if (floatingActionButton != null) {
        content = Stack(
          children: [
            content,
            Positioned(bottom: 16, right: 16, child: floatingActionButton!),
          ],
        );
      }

      return CupertinoPageScaffold(
        backgroundColor: effectiveBackgroundColor,
        navigationBar:
            navigationBar ??
            (title != null
                ? CupertinoNavigationBar(
                    middle: Text(
                      title!,
                      style: TextStyle(
                        color: AppColors.kTextPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: AppColors.kCard,
                    border: Border(
                      bottom: BorderSide(color: AppColors.kBorder, width: 0.5),
                    ),
                  )
                : null),
        child: content,
      );
    }

    // Material Design pour Android
    return Scaffold(
      backgroundColor: effectiveBackgroundColor,
      appBar:
          appBar ??
          (title != null
              ? AppBar(
                  title: Text(
                    title!,
                    style: TextStyle(
                      color: AppColors.kTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColors.kCard,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  iconTheme: IconThemeData(color: AppColors.kTextPrimary),
                )
              : null),
      body: useSafeArea ? SafeArea(child: body) : body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
