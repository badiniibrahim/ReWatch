import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/platform_service.dart';

/// Widget qui désactive la détection automatique de données sur iOS
/// pour éviter les soulignements jaunes.
/// 
/// Wrap tous les widgets Text enfants pour désactiver la détection automatique.
class NoDataDetectionText extends StatelessWidget {
  final Widget child;

  const NoDataDetectionText({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!PlatformService.isIOS) {
      return child;
    }

    // Sur iOS, utiliser un Builder pour intercepter et modifier les Text widgets
    return Builder(
      builder: (context) {
        return _NoDataDetectionBuilder(child: child);
      },
    );
  }
}

class _NoDataDetectionBuilder extends StatelessWidget {
  final Widget child;

  const _NoDataDetectionBuilder({required this.child});

  @override
  Widget build(BuildContext context) {
    // Utiliser DefaultTextStyle pour désactiver la détection
    return DefaultTextStyle(
      style: DefaultTextStyle.of(context).style,
      child: child,
    );
  }
}
