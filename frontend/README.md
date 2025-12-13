# École Inscription - Frontend Flutter

Application Flutter pour l'inscription scolaire avec vérification de documents.

## Prérequis

- Flutter SDK 3.0+
- Android Studio / VS Code
- Émulateur Android ou Chrome pour le web

## Installation

### 1. Installer les dépendances

```bash
cd frontend
flutter pub get
```

### 2. Configuration de l'API

Le frontend est configuré pour se connecter à `http://localhost:8000` par défaut.

Pour tester sur Android émulateur, modifiez `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

Pour tester sur un appareil physique, utilisez l'IP de votre machine:
```dart
static const String baseUrl = 'http://192.168.1.X:8000';
```

## Lancement de l'application

### Web (Chrome)
```bash
flutter run -d chrome
```

### Android
```bash
flutter run -d android
```

### Liste des appareils disponibles
```bash
flutter devices
```

## Fonctionnalités

### Pour CANDIDAT
- ✅ Inscription et connexion
- ✅ Consultation des offres validées
- ✅ Détails d'une offre
- ✅ Soumission de candidature avec upload de documents (CIN + Baccalauréat)
- ✅ Vérification OCR automatique des documents
- ✅ Consultation de ses candidatures

### Pour RECRUTEUR
- ✅ Création d'offres
- ✅ Modification/suppression de ses offres
- ✅ Visualisation des candidats

### Pour ADMIN
- ✅ Validation/rejet des offres en attente
- ✅ Gestion des utilisateurs
- ✅ Vue d'ensemble du système

## Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée
├── models/                   # Modèles de données
│   ├── user.dart
│   ├── offre.dart
│   └── candidature.dart
├── services/                 # Services
│   ├── api_service.dart      # Client HTTP Dio
│   └── storage_service.dart  # Stockage sécurisé JWT
├── providers/                # State management (Provider)
│   ├── auth_provider.dart
│   ├── offres_provider.dart
│   └── candidatures_provider.dart
├── screens/                  # Écrans de l'application
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── candidat/
│   │   ├── home_screen.dart
│   │   └── offre_details_screen.dart
│   ├── recruteur/
│   │   └── recruteur_home_screen.dart
│   └── admin/
│       └── admin_home_screen.dart
└── widgets/                  # Composants réutilisables
```

## Test de l'application

### 1. Démarrer le backend
Assurez-vous que le backend FastAPI est en cours d'exécution sur `http://localhost:8000`.

### 2. Créer un compte
- Lancez l'application Flutter
- Cliquez sur "S'inscrire"
- Choisissez un rôle (candidat, recruteur)
- Remplissez le formulaire

### 3. Tester les fonctionnalités
- **Candidat**: Parcourez les offres et soumettez une candidature
- **Recruteur**: Créez une nouvelle offre
- **Admin**: Connectez-vous avec un compte admin pour valider les offres

## Permissions Android

Pour l'upload d'images sur Android, les permissions suivantes sont configurées dans `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

## Troubleshooting

### Erreur de connexion à l'API
- Vérifiez que le backend est en cours d'exécution
- Vérifiez l'URL dans `api_service.dart`
- Pour Android émulateur, utilisez `10.0.2.2` au lieu de `localhost`

### Erreur lors de l'upload d'images
- Vérifiez les permissions dans AndroidManifest.xml
- Sur iOS, vérifiez Info.plist pour les permissions photo

### Erreur de dépendances
```bash
flutter clean
flutter pub get
```

## Build Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### Web
```bash
flutter build web --release
```
