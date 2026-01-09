# 🎨 ReWatch - Design System & Vision

## 🧠 Philosophie Produit

ReWatch n'est pas juste un tracker, c'est le compagnon premium du cinéphile moderne.
L'interface s'efface devant le contenu (posters, art visuals) mais procure un plaisir tactile à chaque interaction.

**Mots-clés :** Cinématique, Immersif, Fluide, Premium, "Finger-friendly".

---

## 💎 Identité Visuelle

### 1. Palette de Couleurs "Cinema"

Nous adoptons une approche **"Dark Mode First"** (le cinéma se consomme dans le noir).

#### 🌑 Dark Mode (Standard)

- **Background** : `#0A0A0A` (Noir profond, pas OLED pur pour éviter le smearing, mais très sombre)
- **Surface** : `#161616` (Cartes, Sheets)
- **Surface Elevated** : `#212121` (Modales, Popups)
- **Primary Brand** : `#7F5AF0` (Violet "Electric Iris" - Mystère, Créativité, Premium)
- **Secondary Accent** : `#2CB67D` (Vert "Success" - Progression, Validation)
- **Text Primary** : `#FFFFFF` (Blanc pur)
- **Text Secondary** : `#94A1B2` (Gris froid)
- **Divider** : `#2D2D2D`

#### ☀️ Light Mode (Adaptatif)

- **Background** : `#FAFAFA` (Blanc cassé)
- **Surface** : `#FFFFFF` (Blanc pur)
- **Primary Brand** : `#6246EA` (Violet plus profond pour le contraste)
- **Text Primary** : `#16161A` (Noir doux)

### 2. Typographie

Utilisation de **Sora** (actuellement installée) pour son caractère géométrique et moderne.

- **Headings** : Sora Bold (Titres, Chiffres clés)
- **Body** : Sora Regular (Lisibilité)
- **Taille de base** : 16sp (Body), 32sp (H1), 24sp (H2)

---

## 🧱 Composants Core (Atomic Design)

### Boutons

- **Primary** : Fond Brand Color (`#7F5AF0`), Texte Blanc, Radius `16px`, Hauteur `56px`. Shadow colorée légère.
- **Secondary** : Fond Surface (`#212121` Dark / `#F0F0F0` Light), Texte Brand.
- **Ghost** : Texte seul (pour les actions secondaires).

### Cards (Posters)

- **Aspect Ratio** : 2:3 (Standard affiche cinéma).
- **Radius** : `12px` (Soft).
- **Elevation** : Shadow subtile `0 4px 20px rgba(0,0,0,0.3)`.
- **Comportement** : Scale up léger au touch (micro-interaction).

### Navigation

- **Bottom Bar** : Translucide (Blur background), icônes stroke (2px), label active seulement ou toujours affiché (à tester).
- **Status Bar** : Transparente.

---

## 📱 UX & Patterns

### Onboarding

- **3 Slides Max** :
  1. "Centralisez tout" (Visuel: Logos Netflix/Disney+ flottants)
  2. "Ne cherchez plus" (Visuel: Recherche rapide)
  3. "Partagez" (Visuel: Stats)
- **Action** : Gros bouton "Commencer" (Sticky bottom).

### Home

- **Section "Reprendre"** : Cards horizontales avec barre de progression très visible.
- **Section "Watchlist"** : Grid verticale.
- **Empty States** : Illustrations vectorielles minimalistes (pas de gris triste, utiliser la Primary Color avec opacité).

---

## 🚀 Prochaines Étapes Techniques

1. Mettre à jour `app_colors.dart` avec la nouvelle palette.
2. Refondre `app_themes.dart` pour intégrer les styles de boutons, inputs, et cards.
3. Créer les widgets de base (`PrimaryButton`, `MovieCard`, `SectionHeader`).
