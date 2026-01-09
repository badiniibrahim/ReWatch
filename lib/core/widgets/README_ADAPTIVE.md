# Widgets Adaptatifs

Ce dossier contient des widgets qui s'adaptent automatiquement à la plateforme :
- **iOS** : Utilise Cupertino Design (design natif iOS)
- **Android** : Utilise Material Design (design natif Android)

## Utilisation

### Import

```dart
import 'package:rewatch/core/widgets/adaptive_widgets.dart';
```

## Widgets Disponibles

### AdaptiveScaffold

Remplace `Scaffold` pour une expérience native sur chaque plateforme.

```dart
AdaptiveScaffold(
  title: 'Mon Titre',
  body: YourContent(),
)
```

**Sur iOS** : Utilise `CupertinoPageScaffold` avec `CupertinoNavigationBar`
**Sur Android** : Utilise `Scaffold` avec `AppBar`

### AdaptiveButton

Bouton qui s'adapte à la plateforme.

```dart
AdaptiveButton(
  text: 'Continuer',
  onPressed: () {
    // Action
  },
)
```

**Sur iOS** : Utilise `CupertinoButton`
**Sur Android** : Utilise `ElevatedButton`

### AdaptiveTextField

Champ de texte adaptatif.

```dart
AdaptiveTextField(
  placeholder: 'Entrez votre email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
)
```

**Sur iOS** : Utilise `CupertinoTextField`
**Sur Android** : Utilise `TextField`

### AdaptiveDialog

Dialog adaptatif.

```dart
AdaptiveDialog.show(
  context: context,
  title: 'Confirmation',
  content: 'Êtes-vous sûr ?',
  actions: [
    AdaptiveDialogAction(
      text: 'Annuler',
      onPressed: () {},
    ),
    AdaptiveDialogAction(
      text: 'Confirmer',
      isDefault: true,
      onPressed: () {},
    ),
  ],
);
```

**Sur iOS** : Utilise `CupertinoAlertDialog`
**Sur Android** : Utilise `AlertDialog`

### AdaptiveSnackbar

Snackbar adaptatif.

```dart
// Snackbar simple
AdaptiveSnackbar.show(
  title: 'Information',
  message: 'Opération réussie',
);

// Snackbar d'erreur
AdaptiveSnackbar.showError(
  title: 'Erreur',
  message: 'Une erreur est survenue',
);

// Snackbar de succès
AdaptiveSnackbar.showSuccess(
  title: 'Succès',
  message: 'Opération réussie',
);
```

**Sur iOS** : Utilise `CupertinoAlertDialog` (car iOS n'a pas de snackbar)
**Sur Android** : Utilise `SnackbarHelper` (qui utilise `ScaffoldMessenger` de manière sûre)

### AdaptiveModalBottomSheet

Modal bottom sheet adaptatif.

```dart
// Modal avec actions
AdaptiveModalBottomSheet.show(
  context: context,
  title: 'Options',
  content: Text('Choisissez une option'),
  actions: [
    AdaptiveModalAction(
      text: 'Option 1',
      onPressed: () {},
    ),
    AdaptiveModalAction(
      text: 'Option 2',
      onPressed: () {},
      isDestructive: true,
    ),
  ],
);

// Modal simple avec contenu personnalisé
AdaptiveModalBottomSheet.show(
  context: context,
  title: 'Détails',
  content: YourCustomWidget(),
);
```

**Sur iOS** : Utilise `CupertinoActionSheet` (si actions) ou `showCupertinoModalPopup` (si contenu personnalisé)
**Sur Android** : Utilise `showModalBottomSheet` (Material Design)

## Migration depuis les widgets Material

### Avant (Material uniquement)

```dart
Scaffold(
  appBar: AppBar(title: Text('Titre')),
  body: Column(
    children: [
      TextField(
        decoration: InputDecoration(hintText: 'Email'),
      ),
      ElevatedButton(
        onPressed: () {},
        child: Text('Valider'),
      ),
    ],
  ),
)
```

### Après (Adaptatif)

```dart
AdaptiveScaffold(
  title: 'Titre',
  body: Column(
    children: [
      AdaptiveTextField(
        placeholder: 'Email',
      ),
      AdaptiveButton(
        text: 'Valider',
        onPressed: () {},
      ),
    ],
  ),
)
```

## Détection de Plateforme

Pour détecter manuellement la plateforme :

```dart
import 'package:rewatch/core/services/platform_service.dart';

if (PlatformService.isIOS) {
  // Code spécifique iOS
} else if (PlatformService.isAndroid) {
  // Code spécifique Android
}
```

## Thèmes

Les thèmes sont définis dans `core/config/app_themes.dart` :

- `AppThemes.materialTheme` : Thème Material pour Android
- `AppThemes.cupertinoTheme` : Thème Cupertino pour iOS

Les deux thèmes utilisent les mêmes couleurs de base (`AppColors`) pour une cohérence visuelle.

