# Prompt de Recréation - Application Médecin Remplaçant

**Instructions :** Copiez le prompt ci-dessous et donnez-le à Claude pour recréer exactement cette application.

---

## PROMPT À COPIER/COLLER

```
Je souhaite créer une application web Flutter (PWA) pour la gestion des remplacements médicaux avec les spécifications exactes suivantes :

## CONTEXTE
Application destinée à un médecin remplaçant en France pour gérer ses remplacements, calculer automatiquement les charges URSSAF (22% du net avant impôts), et synchroniser ses données dans le cloud.

## FONCTIONNALITÉS PRINCIPALES

### 1. Gestion des remplacements
- Formulaire d'ajout/modification avec :
  - Date de début et date de fin (DatePicker)
  - Nom du médecin remplacé
  - Nombre de jours (calculé automatiquement entre les dates)
  - Taux de rétrocession (0-100%, slider)
  - Montant avant rétrocession (input)
  - Mode de paiement (dropdown : Virement, Chèque, Espèces, Autre)
  - Date de paiement (optionnel)
  - Statut de paiement (dropdown : En attente, Payé, En retard)
  - Notes (textarea, optionnel)

- Calculs automatiques à afficher :
  - Montant de la rétrocession = montant_avant × taux/100
  - Net avant impôts = montant_avant - rétrocession
  - Charges URSSAF (22%) = net_avant_impots × 0.22
  - Net après charges = net_avant_impots - charges_urssaf

- Liste des remplacements avec :
  - Carte pour chaque remplacement montrant : médecin, dates, montant net, statut
  - Recherche et filtres (par statut, par période)
  - Tri (par date, par montant)
  - Actions : Modifier, Supprimer
  - État vide avec illustration si aucun remplacement

### 2. Statistiques
Écran avec cards montrant :
- Nombre total de remplacements
- Total des revenus (somme des montants avant rétrocession)
- Total des charges URSSAF
- Total de la rétrocession
- Graphiques de visualisation (optionnel)

### 3. Documents
- Association de documents aux remplacements (contrats, factures)
- Upload et gestion de fichiers
- Liste des documents avec preview

### 4. Notifications
- Système de rappels automatiques :
  - Paiement à venir (7 jours avant)
  - Paiement en retard
- Badge de compteur sur l'onglet
- Actions : Traiter, Ignorer

### 5. Authentification
- Écran de connexion/inscription avec email + mot de passe
- Confirmation par email (Supabase)
- Réinitialisation de mot de passe
- Option "Continuer sans compte" (mode local uniquement)
- Écran d'onboarding au premier lancement (3 slides)

### 6. Synchronisation Cloud
- Stockage local : Hive (IndexedDB sur web)
- Stockage cloud : Supabase (PostgreSQL)
- Bouton de synchronisation manuelle dans les paramètres
- Sync bidirectionnel : local → cloud puis cloud → local

### 7. Paramètres
- Gestion du compte (email affiché, bouton déconnexion)
- Bouton de synchronisation avec indicateur de statut
- Sauvegarde/Restauration des données (export/import JSON)
- Mode sombre/clair (toggle)
- Section "À propos" avec version, licences, contact

## DESIGN & UX

### Thème
- Couleur principale : Indigo (#6366f1)
- Couleur secondaire : Violet/Purple
- Mode sombre : gradient noir → indigo foncé
- Mode clair : gradient blanc → indigo très clair
- Effet glass morphism sur les cartes (fond semi-transparent, blur)
- Material Design 3
- Langue : Français uniquement

### Navigation
- Bottom Navigation Bar avec 4 onglets :
  1. Remplacements (icône : briefcase)
  2. Statistiques (icône : chart)
  3. Documents (icône : folder)
  4. Notifications (icône : bell, avec badge)
- FAB (Floating Action Button) pour ajouter un remplacement

### Écrans clés
1. **Onboarding** (3 slides) :
   - Slide 1 : Bienvenue, présentation de l'app
   - Slide 2 : Gestion simplifiée des remplacements
   - Slide 3 : Calcul automatique URSSAF
   - Bouton "Commencer" à la fin

2. **Auth** :
   - Formulaire login/signup dans une glass card
   - Toggle entre "Connexion" et "Inscription"
   - Bouton "Mot de passe oublié ?"
   - Bouton "Continuer sans compte" en bas

3. **Home** :
   - AppBar avec titre et actions (recherche, filtres)
   - Liste de cartes des remplacements
   - FAB pour ajouter
   - États vides avec illustrations

4. **Add/Edit Remplacement** :
   - Formulaire scrollable
   - Validation des champs
   - Calculs en temps réel affichés en bas
   - Boutons "Annuler" et "Enregistrer"

5. **Detail** :
   - Toutes les infos du remplacement
   - Boutons d'actions (Modifier, Supprimer)
   - Liste des documents associés

6. **Statistics** :
   - Cards avec icônes et chiffres clés
   - Utiliser des couleurs différentes par stat
   - Animations au chargement (optionnel)

7. **Settings** :
   - Liste avec sections
   - Section "Compte & Synchronisation" :
     - Email de l'utilisateur connecté
     - Bouton "Synchroniser" avec spinner
     - Bouton "Se déconnecter"
   - Section "Données" :
     - Sauvegarder les données
     - Restaurer les données
   - Section "Apparence" :
     - Toggle mode sombre
   - Section "À propos"

## ARCHITECTURE TECHNIQUE

### Stack
- Framework : Flutter 3.x (Web uniquement pour commencer)
- State Management : Provider
- Local DB : Hive avec TypeAdapters pour Remplacement, Notification, Document
- Cloud DB : Supabase (PostgreSQL avec RLS)
- Auth : Supabase Auth (email/password)
- Déploiement : GitHub Pages

### Structure des fichiers
```
lib/
├── main.dart
├── models/
│   ├── remplacement.dart (avec calculs URSSAF en getters)
│   ├── notification_model.dart
│   └── document.dart
├── providers/
│   ├── remplacement_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── onboarding_screen.dart
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── add_remplacement_screen.dart
│   ├── remplacement_detail_screen.dart
│   ├── statistics_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── database_service.dart (Hive)
│   ├── supabase_service.dart
│   └── backup_service.dart
├── widgets/
│   ├── glass_card.dart
│   ├── stat_card.dart
│   └── empty_state.dart
└── utils/
    └── liquid_theme.dart
```

### Modèle Remplacement (Hive + Supabase)
```dart
@HiveType(typeId: 0)
class Remplacement extends HiveObject {
  @HiveField(0)
  String id; // UUID

  @HiveField(1)
  DateTime dateDebut;

  @HiveField(2)
  DateTime dateFin;

  @HiveField(3)
  String medecinRemplace;

  @HiveField(4)
  double nombreJours;

  @HiveField(5)
  int tauxRetrocession; // 0-100

  @HiveField(6)
  double montantAvantRetrocession;

  @HiveField(7)
  String? modePaiement;

  @HiveField(8)
  DateTime? datePaiement;

  @HiveField(9)
  String statutPaiement; // 'En attente', 'Payé', 'En retard'

  @HiveField(10)
  String? notes;

  @HiveField(11)
  DateTime? createdAt;

  @HiveField(12)
  DateTime? updatedAt;

  // Getters pour les calculs
  double get montantRetrocession => montantAvantRetrocession * (tauxRetrocession / 100);
  double get netAvantImpots => montantAvantRetrocession - montantRetrocession;
  double get chargesUrssaf => netAvantImpots * 0.22;
  double get netApresCharges => netAvantImpots - chargesUrssaf;
  double get montantNet => netAvantImpots; // Alias
}
```

### Base de données Supabase
Table `remplacements` avec colonnes :
- id (UUID, PK)
- user_id (UUID, FK vers auth.users)
- date_debut (DATE)
- date_fin (DATE)
- medecin_remplace (TEXT)
- nombre_jours (REAL)
- taux_retrocession (INTEGER)
- montant_avant_retrocession (REAL)
- mode_paiement (TEXT)
- date_paiement (DATE)
- statut_paiement (TEXT)
- notes (TEXT)
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)

RLS Policies : SELECT, INSERT, UPDATE, DELETE basées sur `auth.uid() = user_id`

### Supabase Service
```dart
class SupabaseService {
  // Singleton
  static const String _supabaseUrl = 'À CONFIGURER';
  static const String _supabaseAnonKey = 'À CONFIGURER';

  // Auth methods
  Future<AuthResponse> signUp({String email, String password, String emailRedirectTo});
  Future<AuthResponse> signIn({String email, String password});
  Future<void> signOut();
  Future<void> resetPassword(String email, String redirectTo);

  // Sync methods
  Future<int> syncToCloud(List<Remplacement> localRemplacements);
  Future<List<Remplacement>> fetchFromCloud();
  Future<void> deleteFromCloud(String id);
  Future<List<Remplacement>> fullSync(List<Remplacement> localData);
}
```

### Build & Deploy
- Build web avec : `flutter build web --release --base-href /medecin-remplacant/`
- Déployer sur GitHub Pages (branche gh-pages)
- La branche gh-pages doit contenir UNIQUEMENT les fichiers du dossier build/web

## WORKFLOW

1. Créer le projet Flutter
2. Ajouter les dépendances (provider, hive, supabase_flutter, intl, file_picker, shared_preferences, flutter_native_splash)
3. Configurer Hive avec les TypeAdapters
4. Créer les modèles (Remplacement, Notification, Document)
5. Créer le DatabaseService (Hive)
6. Créer les écrans de base (Onboarding, Auth, Home)
7. Implémenter le Provider pour les remplacements
8. Créer le formulaire d'ajout avec calculs automatiques
9. Ajouter les statistiques
10. Configurer Supabase (projet, table, RLS)
11. Créer le SupabaseService
12. Intégrer l'authentification
13. Implémenter la synchronisation
14. Ajouter les documents et notifications
15. Configurer le thème et les assets
16. Builder pour web et déployer sur GitHub Pages
17. Configurer le PWA (manifest.json, icônes, splash screen)

## DÉTAILS IMPORTANTS

### Calcul des jours
```dart
int calculateDays(DateTime start, DateTime end) {
  return end.difference(start).inDays + 1;
}
```

### Calcul URSSAF
Toujours 22% du net avant impôts :
```dart
double chargesUrssaf = (montantAvantRetrocession - montantRetrocession) * 0.22;
```

### Notifications automatiques
Générer au chargement des remplacements :
- Si date_paiement - 7 jours <= aujourd'hui ET statut != 'Payé' → notification "Paiement à venir"
- Si date_paiement < aujourd'hui ET statut != 'Payé' → notification "Paiement en retard"

### Synchronisation
Flow :
1. Envoyer toutes les données locales vers Supabase (upsert)
2. Récupérer toutes les données de Supabase
3. Remplacer les données locales par les données cloud
4. Afficher un message de succès

### Auth State
- main.dart gère le routing : Onboarding → Auth → Home
- Écouter authStateChanges de Supabase
- SharedPreferences pour savoir si onboarding vu et si auth skippée

### PWA
- manifest.json avec :
  - name: "Médecin Remplaçant"
  - short_name: "Remplaçant"
  - theme_color: "#6366f1"
  - background_color: "#1a1a2e"
  - display: "standalone"
  - lang: "fr-FR"
- index.html avec meta tags pour iOS :
  - apple-mobile-web-app-capable
  - apple-mobile-web-app-status-bar-style
  - apple-mobile-web-app-title
- Icônes : 192x192, 512x512, maskable
- Splash screens pour différentes tailles

## CONFIGURATION FINALE

Après création :

1. **Créer un projet Supabase** :
   - Région : EU (Frankfurt ou Ireland)
   - Récupérer l'URL et l'anon key
   - Créer la table remplacements avec RLS
   - Activer Email Auth
   - Configurer Site URL et Redirect URLs

2. **Créer un repo GitHub** :
   - Nom : medecin-remplacant
   - Public
   - Activer GitHub Pages sur branche gh-pages

3. **Build et deploy** :
   - `flutter build web --release --base-href /medecin-remplacant/`
   - Copier build/web vers branche gh-pages
   - Push

4. **Configurer Supabase Auth URLs** :
   - Site URL : https://VOTRE-USERNAME.github.io/medecin-remplacant/
   - Redirect URLs : https://VOTRE-USERNAME.github.io/medecin-remplacant/**

L'application sera accessible sur : https://VOTRE-USERNAME.github.io/medecin-remplacant/

Créer l'application exactement comme décrit ci-dessus.
```

---

## NOTES POUR LA RECRÉATION

1. **Ordre de développement :** Suivre le workflow étape par étape pour éviter les erreurs de dépendances.

2. **Tests fréquents :** Tester après chaque fonctionnalité majeure, surtout les calculs URSSAF.

3. **Supabase :** Configurer d'abord en mode développement (URL locale), puis en production.

4. **GitHub Pages :** Le `--base-href` est CRITIQUE. Sans ça, les assets ne chargeront pas.

5. **Hive TypeAdapters :** Générer avec build_runner dès que les modèles sont créés.

6. **État vide :** Ne pas oublier les empty states pour une meilleure UX.

7. **Validation :** Valider tous les formulaires (email, montants positifs, dates cohérentes).

8. **Responsive :** L'app doit fonctionner sur mobile, tablette et desktop.

9. **Performance :** Optimiser les builds (tree-shaking des icônes activé par défaut).

10. **Sécurité :** Jamais mettre de secrets dans le code. L'anon key Supabase est publique, c'est normal.

---

**Ce prompt a été testé et validé le 8 février 2026.**
**Il recrée exactement l'application déployée sur https://pial974.github.io/medecin-remplacant/**
