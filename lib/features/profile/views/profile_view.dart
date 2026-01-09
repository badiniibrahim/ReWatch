import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/adaptive_widgets.dart';
import '../../auth/domain/entities/user.dart';
import '../controllers/profile_controller.dart';
import 'permission_test_view.dart';
import 'watch_stats_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      // No standard AppBar title for a custom look
      title: '',
      backgroundColor: AppColors.kBackground,
      body: Obx(() {
        if (controller.currentUser.value == null) {
          return _buildNotLoggedInState(context);
        }

        return _buildProfileContent(context);
      }),
    );
  }

  Widget _buildNotLoggedInState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.kSurfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Icon(
              FluentIcons.person_24_regular,
              size: 48,
              color: AppColors.kTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'profile_not_logged_in'.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.kTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          AdaptiveButton(
            text: 'auth_signIn'.tr,
            onPressed: () {
              AdaptiveSnackbar.show(
                title: 'info'.tr,
                message: 'auth_signInComingSoon'.tr,
              );
            },
            backgroundColor: AppColors.kPrimary,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final user = controller.currentUser.value!;
    // Récupérer le WatchHomeController pour accéder aux items
    // final watchController = Get.find<WatchHomeController>();

    return CustomScrollView(
      slivers: [
        // App Bar / Header Custom
        SliverAppBar(
          expandedHeight: 220.0,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.kBackground,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildUserHeader(context, user),
          ),
          elevation: 0,
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // VIP / Credits Banner
                _buildCreditsBanner(context, user),

                const SizedBox(height: 32),

                // Sections
                _buildSectionHeader('profile_section_app'.tr),
                _buildSectionContainer(
                  items: [
                    _SectionItem(
                      icon: FluentIcons.data_bar_vertical_24_regular,
                      title: 'profile_stats_title'.tr,
                      titleColor: AppColors.kTextPrimary,
                      iconColor: AppColors
                          .kPrimary, // Changed from kSecondary to kPrimary (common color)
                      onTap: () => Get.to(() => const WatchStatsView()),
                    ),
                    _SectionItem(
                      icon: FluentIcons.translate_24_regular,
                      title: 'profile_language'.tr,
                      titleColor: AppColors.kTextPrimary,
                      iconColor: AppColors.kPrimary,
                      onTap: null,
                      hasSwitch: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('profile_section_legal'.tr),
                _buildSectionContainer(
                  items: [
                    _SectionItem(
                      icon: FluentIcons.document_text_24_regular,
                      title: 'profile_terms_conditions'.tr,
                      iconColor: AppColors.kTextSecondary,
                      titleColor: AppColors.kTextPrimary,
                      onTap: controller.openTermsAndConditions,
                    ),
                    _SectionItem(
                      icon: FluentIcons.shield_24_regular,
                      title: 'profile_privacy_policy'.tr,
                      iconColor: AppColors.kTextSecondary,
                      titleColor: AppColors.kTextPrimary,
                      onTap: controller.openPrivacyPolicy,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('profile_section_account'.tr),
                _buildSectionContainer(
                  items: [
                    _SectionItem(
                      icon: FluentIcons.delete_24_regular,
                      title: 'profile_delete_account'.tr,
                      iconColor: AppColors.kError,
                      titleColor: AppColors.kError,
                      onTap: controller.deleteAccount,
                      isDestructive: true,
                    ),
                  ],
                ),

                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('profile_section_debug'.tr),
                  _buildSectionContainer(
                    items: [
                      _SectionItem(
                        icon: FluentIcons.bug_24_regular,
                        title: 'profile_test_permissions'.tr,
                        iconColor: AppColors.kInfo,
                        titleColor: AppColors.kTextPrimary,
                        onTap: () {
                          Get.to(() => const PermissionTestView());
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                Center(
                  child: SizedBox(
                    width: 200, // Fixed width for centered look
                    child: AdaptiveButton(
                      text: 'profile_logout'.tr,
                      onPressed: controller.signOut,
                      backgroundColor: AppColors.kSurfaceElevated,
                      textColor: AppColors.kTextPrimary,
                      height: 52,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Center(child: _buildFooter(context)),

                const SizedBox(height: 48), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeader(BuildContext context, User user) {
    return Container(
      color: AppColors.kBackground, // Solid color, no gradient
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40), // Safe area approx
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.kPrimary.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.kPrimary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.kSurfaceElevated,
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.kTextPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsBanner(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E), // Solid dark color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.kWarning.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FluentIcons.star_24_filled,
              color: AppColors.kWarning,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ReWatch Premium",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Membre depuis 2024", // Placeholder dynamic later
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.kTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<_SectionItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildSectionItem(items[i]),
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.kBorder.withValues(alpha: 0.3),
                indent: 56,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionItem(_SectionItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: item.iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, color: item.iconColor, size: 20),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: item.titleColor,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: item.hasSwitch
          ? GetX<ProfileController>(
              // Use GetX for precise updates inside tile
              builder: (controller) => Switch.adaptive(
                value: controller.isFrench.value,
                onChanged: (value) => controller.changeLanguage(value),
                activeColor: AppColors.kPrimary,
              ),
            )
          : Icon(
              FluentIcons.chevron_right_24_regular,
              color: AppColors.kTextTertiary,
              size: 20,
            ),
      onTap: item.onTap,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Text(
            'ReWatch',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.kTextTertiary.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.appVersion.value.isNotEmpty
                ? 'v${controller.appVersion.value}'
                : 'v1.0.0',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.kTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionItem {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color titleColor;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool hasSwitch;

  const _SectionItem({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.titleColor,
    this.onTap,
    this.isDestructive = false,
    this.hasSwitch = false,
  });
}
