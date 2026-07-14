# SecureInvoice AI - God Tier 🚀

Bienvenue dans **SecureInvoice AI**, l'application ultime de gestion de factures alimentée par l'Intelligence Artificielle. Ce projet a été pensé pour offrir une expérience utilisateur ("Epic Design" & Glassmorphism en Dark Mode Neon) tout en fournissant des fonctionnalités puissantes de scan OCR et de détection de fraudes.

## 🌟 Fonctionnalités

*   **Design Peak & Dark Mode** : Interface utilisateur God-Tier utilisant des palettes sombres et des accents Neon Purple pour une esthétique moderne et luxueuse.
*   **Scan OCR & Importation PDF** : Extraction automatisée des données via la caméra ou l'importation de documents avec analyse de fraude.
*   **Tableau de bord dynamique** : Suivi des indicateurs clés (KPIs), statuts des factures et alertes en temps réel.
*   **Architecture Cross-Platform** : Construit avec Flutter 3+ pour une fluidité native sur iOS et Android.
*   **Support Multi-rôle** : Gestion des accès pour Clients, Comptables et Administrateurs.

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

## 💡 Notes Techniques (Pour les développeurs)
*   **Compile SDK** : Ce projet est forcé à utiliser `compileSdkVersion 36` dans `android/build.gradle.kts` pour éviter les conflits avec certains packages comme `file_picker`.
*   **Thème** : Le thème global est défini dans `main.dart` utilisant la police `Outfit` et des couleurs de fond `0xFF121212` (Dark Mode complet).

## 👨‍💻 Créé pour
**Yassine Atrous** - Prêt à dominer la réunion d'aujourd'hui avec ce rendu visuel exceptionnel ! Let's go ! 🔥
