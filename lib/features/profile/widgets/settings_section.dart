import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/adaptive_widgets.dart';

/// Widget pour afficher la section des paramètres du profil.
/// 
/// Affiche les options de paramètres, aide et déconnexion.
class SettingsSection extends StatelessWidget {
  /// Callback pour ouvrir les paramètres.
  final VoidCallback onSettingsTap;
  
  /// Callback pour ouvrir l'aide.
  final VoidCallback onHelpTap;
  
  /// Callback pour déconnecter.
  final VoidCallback onLogoutTap;

  const SettingsSection({
    super.key,
    required this.onSettingsTap,
    required this.onHelpTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'settings_title'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('settings_about'.tr),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  AdaptiveDialog.show(
                    context: context,
                    title: 'settings_about'.tr,
                    content: 'Tok Cook - Version 1.0.0\n\nApplication pour extraire des recettes depuis TikTok.',
                    actions: [
                      AdaptiveDialogAction(
                        text: 'common_close'.tr,
                        onPressed: () {},
                        isDefault: true,
                      ),
                    ],
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text('settings_help'.tr),
                trailing: const Icon(Icons.chevron_right),
                onTap: onHelpTap,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text('profile_logout'.tr),
                onTap: onLogoutTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

