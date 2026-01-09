import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Widget pour afficher l'en-tête du profil utilisateur.
/// 
/// Affiche l'avatar, l'email et les informations de base de l'utilisateur.
class ProfileHeader extends StatelessWidget {
  /// Utilisateur à afficher.
  final User user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final initials = user.email?.substring(0, 1).toUpperCase() ?? 'U';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                initials,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? user.email ?? 'Utilisateur',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (user.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.email!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

