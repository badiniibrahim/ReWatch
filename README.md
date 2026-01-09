# rewatch

Flutter starter kit with GetX, Clean Architecture & Firebase.

## Configuration du Package ID

Après la génération du projet, vous devez **déplacer manuellement** le fichier `MainActivity.kt` pour qu'il corresponde à votre package ID :

### Étapes à suivre :

1. **Vérifiez votre package ID** : Il devrait être `badiniibrahim.rewatch` (ex: `com.example.myapp`)

2. **Déplacez le fichier MainActivity.kt** :
   ```bash
   # Depuis la racine du projet généré
   mkdir -p android/app/src/main/kotlin/badiniibrahim/rewatch
   mv android/app/src/main/kotlin/com/example/temp_flutter_project/MainActivity.kt \
      android/app/src/main/kotlin/badiniibrahim/rewatch/MainActivity.kt
   rm -rf android/app/src/main/kotlin/com
   ```

3. **Vérifiez que le package dans MainActivity.kt est correct** :
   Le fichier devrait commencer par :
   ```kotlin
   package badiniibrahim.rewatch
   ```

### Note importante

Le nom du projet (`project_name`) doit être en **minuscules** et **sans espaces** pour être valide comme package ID. Utilisez des underscores si nécessaire (ex: `my_app` au lieu de `My App`).
