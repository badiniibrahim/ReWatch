import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../../../core/config/app_colors.dart';
import '../../../../../../core/widgets/adaptive_button.dart';
import 'package:rewatch/features/watch/domain/entities/watch_item.dart';

class ShuffleResultDialog extends StatelessWidget {
  final WatchItem item;
  final VoidCallback onSpinAgain;
  final VoidCallback onStartWatching;

  const ShuffleResultDialog({
    super.key,
    required this.item,
    required this.onSpinAgain,
    required this.onStartWatching,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.kSurfaceElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.kBorder.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                "Ce soir, on regarde :",
                style: TextStyle(
                  color: AppColors.kTextSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Poster / Image
              Container(
                height: 250,
                width: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kPrimary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.image != null && item.image!.isNotEmpty
                      ? Image.network(
                          item.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.kTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Platform chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.kSurfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.platform,
                  style: const TextStyle(
                    color: AppColors.kTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onSpinAgain,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: AppColors.kTextSecondary),
                          SizedBox(height: 4),
                          Text(
                            "Autre chose",
                            style: TextStyle(
                              color: AppColors.kTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: AdaptiveButton(
                      text: "C'est parti !",
                      onPressed: onStartWatching,
                      backgroundColor: AppColors.kPrimary,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.kSurfaceVariant,
      child: Center(
        child: Icon(
          item.type == WatchItemType.movie ? Icons.movie : Icons.tv,
          size: 48,
          color: AppColors.kTextSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
