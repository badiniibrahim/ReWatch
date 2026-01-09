import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:rewatch/core/config/app_colors.dart';
import 'package:rewatch/core/widgets/adaptive_button.dart';
import 'package:rewatch/core/widgets/adaptive_scaffold.dart';
import 'package:rewatch/core/widgets/platform_logo_helper.dart';
import 'package:rewatch/features/watch/domain/entities/watch_item.dart';

/// Vue dédiée pour le résultat du mode aléatoire (Shuffle)
class ShuffleSelectionView extends StatefulWidget {
  final WatchItem item;
  final VoidCallback onSpinAgain;
  final VoidCallback onStartWatching;

  const ShuffleSelectionView({
    super.key,
    required this.item,
    required this.onSpinAgain,
    required this.onStartWatching,
  });

  @override
  State<ShuffleSelectionView> createState() => _ShuffleSelectionViewState();
}

class _ShuffleSelectionViewState extends State<ShuffleSelectionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image (Blurred)
          if (widget.item.image != null && widget.item.image!.isNotEmpty)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: ImageFiltered(
                  imageFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.saturation,
                  ), // Black & White
                  child: widget.item.image!.startsWith('http')
                      ? Image.network(widget.item.image!, fit: BoxFit.cover)
                      : Image.file(File(widget.item.image!), fit: BoxFit.cover),
                ),
              ),
            ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.kBackground.withValues(alpha: 0.8),
                    AppColors.kBackground,
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // "Tonight's Pick" Header
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Icon(
                          FluentIcons.sparkle_24_filled,
                          color: AppColors.kPrimary,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "CE SOIR, C'EST...",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: AppColors.kTextSecondary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Main Card
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.kPrimary.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: -10,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Poster Image
                            AspectRatio(
                              aspectRatio: 2 / 3,
                              child: _buildPoster(widget.item),
                            ),

                            // Bottom Info Overlay
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                    Colors.black.withValues(alpha: 0.9),
                                  ],
                                  stops: const [0.0, 0.4, 1.0],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Platform & Type Badges
                                  Row(
                                    children: [
                                      PlatformLogoHelper.getLogo(
                                        widget.item.platform,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          widget.item.type ==
                                                  WatchItemType.series
                                              ? 'SÉRIE'
                                              : 'FILM',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Title
                                  Text(
                                    widget.item.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AdaptiveButton(
                            text: 'Voir les détails',
                            onPressed: widget.onStartWatching,
                            backgroundColor: AppColors.kPrimary,
                            // icon: FluentIcons.eye_24_filled,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            // Restart animation hack
                            _controller.reset();
                            _controller.forward();
                            widget.onSpinAgain();
                          },
                          icon: const Icon(
                            FluentIcons.arrow_counterclockwise_24_regular,
                          ),
                          label: const Text("Choisir autre chose"),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.kTextSecondary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Close button top right
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: IconButton(
              icon: const Icon(
                FluentIcons.dismiss_24_filled,
                color: AppColors.kTextSecondary,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(WatchItem item) {
    if (item.image != null && item.image!.isNotEmpty) {
      bool isUrl = item.image!.startsWith('http');
      return isUrl
          ? Image.network(item.image!, fit: BoxFit.cover)
          : Image.file(File(item.image!), fit: BoxFit.cover);
    }
    return Container(
      color: AppColors.kSurfaceVariant,
      child: Center(
        child: Icon(
          item.type == WatchItemType.series
              ? FluentIcons.movies_and_tv_24_regular
              : FluentIcons.video_24_regular,
          size: 64,
          color: AppColors.kTextSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
