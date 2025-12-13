# 📱 RamzALFiteness - Suivi de Calories Intelligent avec IA

**RamzALFitenesss** est une application Flutter intelligente et conviviale conçue pour aider les utilisateurs à surveiller leur consommation alimentaire, suivre leurs calories et gérer leurs objectifs de santé grâce à la reconnaissance d'images par IA.

## 🎯 Fonctionnalités Principales

### ✅ Authentification
- **Inscription** : Création de compte utilisateur
- **Connexion** : Authentification sécurisée
- **Gestion de session** : Maintien de la session utilisateur

### 📸 Détection Intelligente des Aliments
- **Reconnaissance d'images par IA** : Utilise Google Gemini AI pour identifier les aliments à partir de photos
- **Calcul automatique** : Détection des calories et macronutriments (protéines, glucides, lipides)
- **Source d'image** : Caméra ou galerie photo

### 📊 Suivi Quotidien
- **Tableau de bord** : Vue d'ensemble des calories et macronutriments consommés
- **Objectifs personnalisés** : Calcul automatique des besoins caloriques basés sur le profil utilisateur
- **Indicateurs visuels** : Barres de progression pour suivre l'avancement quotidien

### 📈 Progression Hebdomadaire
- **Graphiques interactifs** : Visualisation des données sur 7 jours
- **Statistiques** : Moyenne, maximum et minimum des calories consommées
- **Analyse des tendances** : Suivi de l'évolution des habitudes alimentaires

### 👤 Profil Utilisateur
- **Onboarding complet** : Configuration initiale du profil (poids, taille, âge, niveau d'activité, genre, objectif)
- **Calcul BMR/TDEE** : Estimation automatique des besoins caloriques
- **Objectifs de macronutriments** : Répartition personnalisée des protéines, glucides et lipides

### ⚙️ Gestion des Repas
- **Ajout de repas** : Via photo ou saisie manuelle
- **Édition** : Modification des informations des repas
- **Suppression** : Retrait des repas enregistrés
- **Historique** : Liste complète des repas de la journée

### 🔧 Paramètres
- **Modification du profil** : Mise à jour des informations utilisateur
- **Déconnexion** : Fermeture de session sécurisée
- **Informations sur l'application** : Version et détails

## 🏗️ Architecture du Projet

L'application suit une **architecture propre (Clean Architecture)** avec séparation claire des responsabilités :

```
lib/
├── main.dart                    # Point d'entrée de l'application
├── core/                        # Logique métier (utilitaires)
│   └── utils/
│       └── calorie_calculator.dart
├── data/                        # Couche de données
│   ├── models/                  # Modèles de données
│   │   ├── food_item.dart
│   │   └── user_data.dart
│   ├── repositories/            # Accès aux données (pattern Repository)
│   │   ├── food_repository.dart
│   │   └── user_repository.dart
│   ├── services/                # Services externes (API)
│   │   ├── auth_service.dart
│   │   └── food_service.dart
│   └── local/                   # Stockage local
│       ├── database_helper.dart
│       ├── database_mobile.dart
│       ├── database_web.dart
│       ├── daos/                # Data Access Objects
│       │   ├── food_item_dao.dart
│       │   ├── user_data_dao.dart
│       │   └── user_dao.dart
│       └── preference_manager.dart
└── presentation/                # Couche de présentation (UI)
    ├── cubit/                   # Gestion d'état (BLoC pattern)
    │   └── food_log_cubit.dart
    ├── screens/                 # Écrans complets
    │   ├── main_screen.dart
    │   ├── home_screen.dart
    │   ├── onboarding_screen.dart
    │   ├── graph_screen.dart
    │   ├── settings_screen.dart
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   ├── meal_detail_screen.dart
    │   └── edit_meal_screen.dart
    └── widgets/                 # Composants UI réutilisables
        ├── daily_tracker.dart
        ├── meal_list.dart
        ├── meal_list_item.dart
        ├── macro_indicator.dart
        └── alert_message_widget.dart
```

### Flux de Données

```
1. INTERACTION UTILISATEUR (UI)
   └─> L'utilisateur appuie sur "Ajouter une photo"

2. GESTION D'ÉTAT (Presentation Layer)
   └─> HomeScreen appelle: context.read<FoodLogCubit>().addMealFromImage(image)

3. LOGIQUE MÉTIER (Cubit Layer)
   └─> FoodLogCubit.addMealFromImage() appelle le repository

4. ACCÈS AUX DONNÉES (Repository Layer)
   └─> FoodRepository.detectFoodFromImage() appelle le service

5. SERVICE EXTERNE (Service Layer)
   └─> FoodService.detectFoodAndCalories() utilise l'API Gemini AI

6. PERSISTANCE DES DONNÉES (Storage Layer)
   └─> FoodRepository.addFoodItem() sauvegarde dans la base de données

7. MISE À JOUR DE L'ÉTAT (Retour à l'UI)
   └─> FoodLogCubit émet un nouvel état → L'UI se reconstruit automatiquement
```

## 🛠️ Technologies Utilisées

### Framework & Langage
- **Flutter** : Framework de développement multiplateforme
- **Dart** : Langage de programmation (SDK ^3.6.0)

### Gestion d'État
- **flutter_bloc** (^8.1.6) : Pattern BLoC pour la gestion d'état réactive

### Base de Données
- **sqflite** (^2.3.0) : Base de données SQLite pour Android/iOS
- **sembast** (^3.4.0) : Base de données NoSQL pour le web
- **sembast_web** (^2.4.2) : Implémentation web de Sembast

### Services Externes
- **flutter_gemini** (^3.0.0) : Intégration avec Google Gemini AI pour la détection d'aliments
- **http** (^1.2.2) : Requêtes HTTP

### Interface Utilisateur
- **fl_chart** (^0.70.0) : Graphiques et visualisations de données
- **percent_indicator** (^4.2.4) : Indicateurs de progression
- **image_picker** (^1.1.2) : Sélection d'images depuis la caméra/galerie

### Stockage & Configuration
- **shared_preferences** (^2.3.4) : Stockage de préférences utilisateur
- **flutter_dotenv** (^5.2.1) : Gestion des variables d'environnement

### Utilitaires
- **json_annotation** (^4.9.0) & **json_serializable** (^6.9.2) : Sérialisation JSON
- **build_runner** (^2.4.14) : Génération de code
- **timeago** (^3.7.0) : Formatage de dates relatives
- **dartz** (^0.10.1) : Programmation fonctionnelle

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- **Flutter SDK** (version 3.6.0 ou supérieure)
- **Dart SDK** (inclus avec Flutter)
- **Android Studio** ou **VS Code** avec les extensions Flutter
- **Git** pour le contrôle de version
- **Clé API Google Gemini** (pour la détection d'aliments par IA)

## 🚀 Installation

### 1. Cloner le Repository

```bash
git clone <url-du-repository>
cd ai_calorie_tracker
```

### 2. Installer les Dépendances

```bash
flutter pub get
```

### 3. Configuration de l'Environnement

Créez un fichier `.env` à la racine du projet :

```env
GEMINI_API_KEY=votre_cle_api_gemini_ici
```

**Comment obtenir une clé API Gemini :**
1. Allez sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Créez un compte ou connectez-vous
3. Générez une nouvelle clé API
4. Copiez la clé dans le fichier `.env`

### 4. Générer le Code (si nécessaire)

Si vous modifiez les modèles avec `@JsonSerializable`, exécutez :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Lancer l'Application

#### Sur Android/iOS
```bash
flutter run
```

#### Sur Web
```bash
flutter run -d chrome
# ou
flutter run -d edge
```

#### Sur un Appareil Spécifique
```bash
flutter devices                    # Lister les appareils disponibles
flutter run -d <device-id>         # Lancer sur un appareil spécifique
```

## 📱 Utilisation

### Premier Lancement

1. **Inscription** : Créez un nouveau compte avec votre email et mot de passe
2. **Onboarding** : Complétez votre profil (poids, taille, âge, niveau d'activité, genre, objectif)
3. **Accueil** : Vous arrivez sur l'écran principal avec votre tableau de bord

### Ajouter un Repas

1. Appuyez sur le bouton **"+"** (floating action button) en bas à droite
2. Choisissez **"Caméra"** ou **"Galerie"**
3. Prenez ou sélectionnez une photo de votre repas
4. L'IA détecte automatiquement les aliments et calcule les calories
5. Le repas est ajouté à votre journal quotidien

### Consulter les Statistiques

1. Naviguez vers l'onglet **"Progress"** (graphique)
2. Visualisez votre progression hebdomadaire
3. Consultez les statistiques (moyenne, maximum, minimum)

### Modifier le Profil

1. Allez dans l'onglet **"Settings"** (paramètres)
2. Appuyez sur **"Edit User Information"**
3. Modifiez vos informations et objectifs

## 🗄️ Base de Données

L'application utilise des bases de données différentes selon la plateforme :

### Mobile (Android/iOS)
- **SQLite** via `sqflite`
- Tables : `users`, `user_data`, `food_items`
- Relations avec clés étrangères

### Web
- **Sembast** (base de données NoSQL)
- Stockage dans IndexedDB du navigateur
- Compatible avec toutes les fonctionnalités

## 🔐 Sécurité

⚠️ **Note importante** : L'authentification actuelle est une implémentation simple pour le développement. Pour la production, il est recommandé d'utiliser :

- **Firebase Authentication** : Solution complète et sécurisée
- **OAuth 2.0** : Authentification via Google, Apple, etc.
- **Backend sécurisé** : API REST avec tokens JWT

Voir `AUTHENTICATION_GUIDE.md` pour plus de détails sur l'implémentation d'une authentification sécurisée.

## 🧪 Tests

Pour exécuter les tests :

```bash
flutter test
```

## 📦 Build pour Production

### Android
```bash
flutter build apk --release          # APK
flutter build appbundle --release    # App Bundle (Google Play)
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. **Fork** le projet
2. Créez une **branche** pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. **Commit** vos changements (`git commit -m 'Add some AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une **Pull Request**

### Guidelines de Code

- Suivez les conventions de nommage Dart/Flutter
- Utilisez des commentaires pour expliquer la logique complexe
- Maintenez la séparation des couches (data, presentation, core)
- Écrivez des tests pour les nouvelles fonctionnalités

## 📝 Documentation Additionnelle

- `PROJECT_ANALYSIS.md` : Analyse détaillée de l'architecture
- `DEVELOPMENT_ROADMAP.md` : Roadmap de développement
- `AUTHENTICATION_GUIDE.md` : Guide d'authentification
- `WEB_COMPATIBILITY_GUIDE.md` : Guide de compatibilité web
- `IMPLEMENTATION_SUMMARY.md` : Résumé des implémentations

## 🐛 Problèmes Connus

- La détection d'aliments par IA peut parfois être imprécise selon la qualité de l'image
- Sur web, certaines fonctionnalités de la caméra peuvent être limitées par le navigateur
- La première connexion peut être plus lente (initialisation de la base de données)

## 📄 Licence

Ce projet est privé et destiné à un usage interne.

## 👥 Équipe

Développé par l'équipe de **Boudchiche**. 
nomeé par **RAJAE , ABDELGHANI , MERYAME , ZAKARIAE**.

## 📞 Support

Pour toute question ou problème, contactez l'équipe de développement. : 
  ####  ZAKARIAE : https://www.linkedin.com/in/zakariae-el-haddouchi-992474339/
  #### ABDELGHANI : https://www.linkedin.com/in/zakariae-el-haddouchi-992474339/
  ####  RAJAE : https://www.linkedin.com/in/zakariae-el-haddouchi-992474339/
  ####  MERYAME : https://www.linkedin.com/in/zakariae-el-haddouchi-992474339/

---

**Version** : 1.0.3  
**Dernière mise à jour** : 2024

