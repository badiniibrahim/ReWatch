import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/adaptive_widgets.dart';
import '../../../routes/app_pages.dart';
import '../../auth/domain/entities/user.dart';
import '../controllers/profile_controller.dart';
import 'permission_test_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'profile_settings'.tr,
      backgroundColor: AppColors.kSurface,
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
          Icon(
            FluentIcons.person_24_regular,
            size: 64,
            color: AppColors.kTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'profile_not_logged_in'.tr,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.kTextPrimary),
          ),
          const SizedBox(height: 24),
          AdaptiveButton(
            text: 'auth_signIn'.tr,
            onPressed: () {
              AdaptiveSnackbar.show(
                title: 'info'.tr,
                message: 'auth_signInComingSoon'.tr,
              );
            },
            backgroundColor: AppColors.kPrimarySolid,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final user = controller.currentUser.value!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildUserSection(context, user)),
          _buildCreditsSection(context, user),

          const SizedBox(height: 24),

          _buildAppSection(context),

          const SizedBox(height: 24),

          _buildSupportSection(context),

          const SizedBox(height: 24),

          _buildLegalSection(context),

          const SizedBox(height: 24),

          _buildAccountSection(context),

          if (kDebugMode) ...[
            const SizedBox(height: 24),
            _buildDebugSection(context),
          ],

          const SizedBox(height: 32),

          _buildLogoutButton(context),

          const SizedBox(height: 24),

          Center(child: _buildFooter(context)),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kPrimarySolid,
            ),
            child: Icon(
              FluentIcons.person_24_filled,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.username,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.kTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsSection(BuildContext context, User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.kPrimarySolid,
            AppColors.kPrimarySolid.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimarySolid.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FluentIcons.star_24_filled,
              size: 24,
              color: Colors.white,
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'profile_section_app'.tr,
      items: [
       

        _SectionItem(
          icon: FluentIcons.translate_24_regular,
          title: 'profile_language'.tr,
          onTap: null,
          hasSwitch: true,
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'profile_section_support'.tr,
      items: [
        _SectionItem(
          icon: FluentIcons.chat_24_regular,
          title: 'profile_leave_review'.tr,
          onTap: controller.leaveReview,
        ),
        _SectionItem(
          icon: FluentIcons.bookmark_24_regular,
          title: 'profile_how_to_save'.tr,
          onTap: () {
            AdaptiveSnackbar.show(
              title: 'info'.tr,
              message: 'profile_how_to_save'.tr,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'profile_section_legal'.tr,
      items: [
        _SectionItem(
          icon: FluentIcons.info_24_regular,
          title: 'profile_terms_conditions'.tr,
          onTap: controller.openTermsAndConditions,
        ),
        _SectionItem(
          icon: FluentIcons.shield_24_regular,
          title: 'profile_privacy_policy'.tr,
          onTap: controller.openPrivacyPolicy,
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'profile_section_account'.tr,
      items: [
        _SectionItem(
          icon: FluentIcons.person_delete_24_regular,
          title: 'profile_delete_account'.tr,
          onTap: controller.deleteAccount,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildDebugSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'profile_section_debug'.tr,
      items: [
        _SectionItem(
          icon: FluentIcons.shield_24_regular,
          title: 'profile_test_permissions'.tr,
          onTap: () {
            Get.to(() => const PermissionTestView());
          },
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_SectionItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.kTextSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.kCard,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.kPrimarySolid.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _buildSectionItem(context, items[i]),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.kBorder.withValues(alpha: 0.5),
                    indent: 56,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionItem(BuildContext context, _SectionItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: item.isDestructive ? AppColors.kError : AppColors.kTextPrimary,
        size: 24,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: item.isDestructive ? AppColors.kError : AppColors.kTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: item.hasSwitch
          ? Obx(
              () => Switch(
                value: controller.isFrench.value,
                onChanged: (value) {
                  controller.changeLanguage(value);
                },
                activeColor: AppColors.kPrimarySolid,
              ),
            )
          : Icon(
              FluentIcons.chevron_right_24_regular,
              color: AppColors.kTextSecondary,
              size: 20,
            ),
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: AdaptiveButton(
        text: 'profile_logout'.tr.toUpperCase(),
        onPressed: controller.signOut,
        backgroundColor: AppColors.kTextPrimary,
        height: 56,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          FluentIcons.food_24_regular,
          size: 24,
          color: AppColors.kTextSecondary,
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            controller.appVersion.value.isNotEmpty
                ? '${'profile_app_version_label'.tr} ${controller.appVersion.value}'
                : 'profile_app_version'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.kTextSecondary),
          ),
        ),
      ],
    );
  }
}

class _SectionItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool hasSwitch;

  const _SectionItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.isDestructive = false,
    this.hasSwitch = false,
  });
}
