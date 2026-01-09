import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/adaptive_widgets.dart';
import '../../../core/services/permission_service.dart';

/// Vue de test des permissions (uniquement en mode debug).
/// 
/// Cette vue permet de tester les permissions de l'application :
/// - Caméra
/// - Galerie
/// - Localisation
/// 
/// Elle n'est accessible qu'en mode debug pour des raisons de sécurité.
class PermissionTestView extends StatelessWidget {
  const PermissionTestView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sécurité : Ne pas afficher en production
    if (!kDebugMode) {
      return AdaptiveScaffold(
        title: 'permission_test'.tr,
        body: const Center(
          child: Text('Cette vue n\'est disponible qu\'en mode debug'),
        ),
      );
    }

    final permissionService = PermissionService();

    return AdaptiveScaffold(
      title: 'permission_test'.tr,
      backgroundColor: AppColors.kSurface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 24),
            _buildPermissionButton(
              context,
              icon: FluentIcons.camera_24_filled,
              title: 'permission_camera'.tr,
              description: 'permission_camera_description'.tr,
              onTap: () => _testCameraPermission(context, permissionService),
            ),
            const SizedBox(height: 16),
            _buildPermissionButton(
              context,
              icon: FluentIcons.image_24_filled,
              title: 'permission_gallery'.tr,
              description: 'permission_gallery_description'.tr,
              onTap: () => _testGalleryPermission(context, permissionService),
            ),
            const SizedBox(height: 16),
            _buildPermissionButton(
              context,
              icon: FluentIcons.location_24_filled,
              title: 'permission_location'.tr,
              description: 'permission_location_description'.tr,
              onTap: () => _testLocationPermission(context, permissionService),
            ),
            const SizedBox(height: 24),
            _buildStatusSection(context, permissionService),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.kPrimarySolid.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            FluentIcons.info_24_filled,
            color: AppColors.kPrimarySolid,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'permission_test_info'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.kTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.kPrimarySolid.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kPrimarySolid.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.kPrimarySolid,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FluentIcons.chevron_right_24_regular,
              color: AppColors.kTextSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    PermissionService permissionService,
  ) {
    return FutureBuilder<Map<String, handler.PermissionStatus>>(
      future: _getAllPermissionStatuses(permissionService),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final statuses = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.kCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'permission_status'.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.kTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusItem(
                context,
                'permission_camera'.tr,
                statuses['camera']!,
              ),
              const SizedBox(height: 12),
              _buildStatusItem(
                context,
                'permission_gallery'.tr,
                statuses['gallery']!,
              ),
              const SizedBox(height: 12),
              _buildStatusItem(
                context,
                'permission_location'.tr,
                statuses['location']!,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String permissionName,
    handler.PermissionStatus status,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (status.isGranted) {
      statusColor = Colors.green;
      statusIcon = FluentIcons.checkmark_circle_24_filled;
      statusText = 'permission_granted'.tr;
    } else if (status.isPermanentlyDenied) {
      statusColor = Colors.red;
      statusIcon = FluentIcons.dismiss_circle_24_filled;
      statusText = 'permission_permanently_denied'.tr;
    } else if (status.isDenied) {
      statusColor = Colors.orange;
      statusIcon = FluentIcons.error_circle_24_filled;
      statusText = 'permission_denied'.tr;
    } else {
      statusColor = AppColors.kTextSecondary;
      statusIcon = FluentIcons.question_circle_24_regular;
      statusText = 'permission_unknown'.tr;
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            permissionName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.kTextPrimary,
            ),
          ),
        ),
        Icon(
          statusIcon,
          color: statusColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<Map<String, handler.PermissionStatus>> _getAllPermissionStatuses(
    PermissionService permissionService,
  ) async {
    final cameraStatus = await permissionService.checkCameraPermission();
    final galleryStatus = await permissionService.checkGalleryPermission();
    final locationStatus = await permissionService.checkLocationPermission();

    return {
      'camera': cameraStatus,
      'gallery': galleryStatus,
      'location': locationStatus,
    };
  }

  Future<void> _testCameraPermission(
    BuildContext context,
    PermissionService permissionService,
  ) async {
    final status = await permissionService.requestCameraPermission();

    _showPermissionResult(
      context,
      'permission_camera'.tr,
      status,
      permissionService,
    );
  }

  Future<void> _testGalleryPermission(
    BuildContext context,
    PermissionService permissionService,
  ) async {
    final status = await permissionService.requestGalleryPermission();

    _showPermissionResult(
      context,
      'permission_gallery'.tr,
      status,
      permissionService,
    );
  }

  Future<void> _testLocationPermission(
    BuildContext context,
    PermissionService permissionService,
  ) async {
    final status = await permissionService.requestLocationPermission();

    _showPermissionResult(
      context,
      'permission_location'.tr,
      status,
      permissionService,
    );
  }

  void _showPermissionResult(
    BuildContext context,
    String permissionName,
    handler.PermissionStatus status,
    PermissionService permissionService,
  ) {
    String message;
    Color backgroundColor;
    Color textColor;

    if (status.isGranted) {
      message = 'permission_camera_granted_success'.tr.replaceAll(
        '',
        permissionName,
      );
      backgroundColor = Colors.green;
      textColor = Colors.white;
    } else if (status.isPermanentlyDenied) {
      message = 'permission_permanently_denied_message'.tr.replaceAll(
        '',
        permissionName,
      );
      backgroundColor = Colors.red;
      textColor = Colors.white;

      // Proposer d'ouvrir les paramètres
      AdaptiveDialog.show(
        context: context,
        title: 'permission_settings_required'.tr,
        content: message,
        actions: [
          AdaptiveDialogAction(
            text: 'common_cancel'.tr,
            onPressed: () {},
          ),
          AdaptiveDialogAction(
            text: 'permission_open_settings'.tr,
            onPressed: () async {
              await permissionService.openAppSettings();
            },
            isDefault: true,
          ),
        ],
      );
      return;
    } else {
      message = 'permission_denied_message'.tr.replaceAll(
        '',
        permissionName,
      );
      backgroundColor = Colors.orange;
      textColor = Colors.white;
    }

    AdaptiveSnackbar.show(
      title: permissionName,
      message: message,
      duration: const Duration(seconds: 3),
      isError: status.isPermanentlyDenied,
      isSuccess: status.isGranted,
    );
  }
}

