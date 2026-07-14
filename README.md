# SecureInvoice AI - God Tier 🚀

[![CI/CD Build](https://github.com/yassinelaatrous/secure-invoice-ai/actions/workflows/ci.yml/badge.svg)](https://github.com/yassinelaatrous/secure-invoice-ai/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Bienvenue dans **SecureInvoice AI**, l'application ultime de gestion de factures alimentée par l'Intelligence Artificielle. Ce projet a été pensé pour offrir une expérience utilisateur ("Epic Design" & Glassmorphism en Dark Mode Neon) tout en fournissant des fonctionnalités puissantes de scan OCR, de vérification de conformité et de détection de fraudes.

---

## 📸 Aperçu de l'Application (Epic Dark Theme)

| Écran de Connexion (Glassmorphic Card & Waves) | Tableau de Bord (KPIs, Graphiques & Actions) |
| :---: | :---: |
| ![Connexion](screenshots/screenshot_login.png) | ![Tableau de Bord](screenshots/screenshot_dashboard.png) |

| Capture OCR & Zones Interactives | Historique & Imports PDF |
| :---: | :---: |
| ![Capture OCR](screenshots/screenshot_capture.png) | ![Imports PDF](screenshots/screenshot_factures.png) |

| Vue Administrateur & Audit de Sécurité |
| :---: |
| ![Admin](screenshots/screenshot_admin.png) |

---

## 🌟 Fonctionnalités

*   **Design Peak & Dark Mode** : Interface utilisateur God-Tier utilisant des palettes sombres, des contrastes Neon Purple (`#8B5CF6`) et des accents Emerald pour une esthétique moderne et luxueuse.
*   **Scan OCR & Importation PDF** : Extraction automatisée des données via la caméra (avec surbrillance des zones de capture sur le document) ou l'importation de documents avec analyse de fraude.
*   **Tableau de bord dynamique** : Suivi des indicateurs clés (KPIs), conformité globale, statuts des factures et alertes en temps réel.
*   **Architecture Cross-Platform** : Construit avec Flutter 3+ pour une fluidité native sur iOS et Android.
*   **Moteur de Règles & Risques** : Analyse automatique de la cohérence de TVA (HT + TVA = TTC), vérification du format IBAN, détection de doublons et comparaison avec un annuaire de confiance.

---

## 🛠️ Comment ouvrir et lancer le projet dans Android Studio (Guide Étape par Étape)

Pour voir l'application tourner sur l'émulateur par vous-même, suivez attentivement ces instructions :

### Étape 1 : Ouvrir le projet dans Android Studio
1. Lancez **Android Studio**.
2. Cliquez sur **Open** (ou "File > Open" si vous êtes déjà dans un autre projet).
3. Naviguez vers le dossier où vous avez enregistré ce projet : `C:\plateforme\mobile` (assurez-vous de bien sélectionner le dossier `mobile` qui contient le code Flutter, et non le dossier backend).
4. Cliquez sur **OK**. Android Studio va charger le projet. Patientez pendant l'indexation (barre de progression en bas à droite).

### Étape 2 : Lancer un Émulateur Android (Téléphone Virtuel)
1. En haut à droite d'Android Studio, repérez l'icône **Device Manager** (un petit téléphone avec le logo Android) et cliquez dessus.
2. Si vous avez déjà un émulateur listé (ex: *Pixel 6 API 33*), cliquez sur le bouton **Play (▷)** à côté de son nom pour le démarrer.
3. Si vous n'en avez pas :
   * Cliquez sur **Create Device**.
   * Choisissez un téléphone (ex: Pixel 6) -> Next.
   * Téléchargez une image système recommandée (ex: API 33 ou API 34) -> Next -> Finish.
   * Lancez-le avec le bouton **Play (▷)**.
4. Le téléphone virtuel apparaîtra sur votre écran. Attendez qu'il soit complètement allumé et sur l'écran d'accueil.

### Étape 3 : Installer les dépendances Flutter
1. Dans Android Studio, ouvrez le fichier `pubspec.yaml` (situé à la racine du projet `mobile`).
2. Une bannière apparaîtra en haut du fichier. Cliquez sur **Pub get** pour télécharger tous les packages nécessaires (ou ouvrez le terminal en bas d'Android Studio et tapez `flutter pub get`).

### Étape 4 : Lancer l'application 🚀
1. Dans la barre d'outils supérieure d'Android Studio, assurez-vous que votre émulateur (ex: `emulator-5554`) est sélectionné dans le menu déroulant des appareils.
2. Assurez-vous que le fichier sélectionné juste à côté est `main.dart`.
3. Cliquez sur le bouton vert **Play (▷)** (Run 'main.dart') en haut à droite.
4. La compilation de l'application va commencer. *(Note : La première compilation (Gradle Build) peut prendre quelques minutes).*
5. Une fois compilée, l'application s'ouvrira automatiquement et de manière fluide sur votre émulateur virtuel ! 🎉

---

## 🧪 Architecture & Validation (PFE Demo)

### Justification de l'Architecture
*   **Base de Données localisée (SQLite)** : Choix délibéré d'utiliser SQLite pour cette démonstration afin de permettre une **évaluation instantanée et sans installation** (pas besoin d'installer, configurer ou orchestrer de serveur de base de données comme PostgreSQL ou MySQL). L'implémentation SQLAlchemy est entièrement abstraite et peut être connectée à une base de données de production (comme PostgreSQL) en modifiant simplement la chaîne de connexion dans le fichier de configuration.
*   **Comptes de Démo** : Les identifiants de test pré-configurés facilitent l'exploration des différents rôles (Client, Comptable, Admin) directement par les évaluateurs du PFE.
*   **Sécurité en Production** : En production réelle, les clés secrètes JWT, les identifiants et les configurations sensibles doivent être chargés uniquement via des variables d'environnement (`.env` ou gestionnaire de secrets sécurisé comme Doppler ou AWS Secrets Manager).

### Tests Automatisés & Qualité
Le projet intègre des tests automatisés pour valider la robustesse du moteur de règles et de détection de risques.
*   **Backend** : Exécutez les tests unitaires avec `python backend/test_invoice.py`.
*   **Mobile** : Exécutez les tests unitaires / widget Flutter avec `flutter test` dans le dossier `mobile`.
*   **CI/CD** : Un workflow GitHub Actions (`.github/workflows/ci.yml`) valide automatiquement chaque push en exécutant l'ensemble de la suite de tests sur les environnements backend et mobile.

---

## 💡 Notes Techniques (Pour les développeurs)
*   **Compile SDK** : Ce projet utilise `compileSdkVersion 36` dans `android/build.gradle.kts` pour éviter les conflits de versions de dépendances avec des plugins comme `file_picker`.
*   **Thème** : Le thème global est défini dans `main.dart` utilisant la police `Outfit` et des couleurs de fond `0xFF121212` (Dark Mode complet).

## 👨‍💻 Créé pour
**Yassine Atrous** - Prêt à dominer la réunion d'aujourd'hui avec ce rendu visuel exceptionnel ! Let's go ! 🔥
