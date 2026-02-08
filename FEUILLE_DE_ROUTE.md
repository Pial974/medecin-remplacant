# Feuille de Route - Application Médecin Remplaçant

## 📱 Vue d'ensemble

Application web progressive (PWA) Flutter pour la gestion des remplacements médicaux avec calcul automatique des charges URSSAF et synchronisation cloud.

**URL de production :** https://pial974.github.io/medecin-remplacant/

---

## 🎯 Fonctionnalités principales

### ✅ Gestion des remplacements
- Ajout/modification/suppression de remplacements
- Calcul automatique des charges URSSAF (22% du montant net)
- Calcul automatique de la rétrocession
- Suivi des paiements (statut : En attente, Payé, En retard)
- Gestion des dates de début et fin
- Ajout de notes pour chaque remplacement
- Filtrage et recherche des remplacements

### ✅ Statistiques
- Nombre total de remplacements
- Total des revenus
- Total des charges URSSAF
- Total de la rétrocession
- Graphiques et visualisations

### ✅ Documents
- Association de documents (contrats, factures, etc.) aux remplacements
- Stockage et gestion des fichiers

### ✅ Notifications
- Rappels pour les paiements à venir (7 jours avant)
- Alertes pour les paiements en retard
- Gestion des notifications (traiter/ignorer)

### ✅ Authentification et Synchronisation
- Création de compte avec email/mot de passe
- Confirmation par email
- Réinitialisation de mot de passe
- Synchronisation cloud automatique avec Supabase
- Stockage local avec Hive (IndexedDB sur web)
- Possibilité d'utiliser l'app sans compte (mode local uniquement)

### ✅ Paramètres
- Mode sombre/clair
- Sauvegarde et restauration des données (JSON)
- Langue : Français
- Gestion du compte (connexion/déconnexion)
- Synchronisation manuelle

### ✅ PWA
- Installation sur l'écran d'accueil
- Fonctionne hors ligne
- Splash screen personnalisé
- Icône d'application personnalisée
- Support iOS et Android

---

## 🏗️ Architecture technique

### Technologies utilisées

**Frontend :**
- Flutter 3.x (Web)
- Provider pour la gestion d'état
- Material Design 3

**Base de données :**
- Hive (local - IndexedDB sur web)
- Supabase (cloud - PostgreSQL)

**Authentification & Backend :**
- Supabase Auth (email/password)
- Supabase Database avec Row Level Security (RLS)

**Déploiement :**
- GitHub Pages
- GitHub repository : https://github.com/Pial974/medecin-remplacant

### Structure du projet

```
lib/
├── main.dart                      # Point d'entrée, routing, auth state
├── models/
│   ├── remplacement.dart          # Modèle principal avec calculs URSSAF
│   ├── notification_model.dart    # Modèle des notifications
│   └── document.dart              # Modèle des documents
├── providers/
│   ├── remplacement_provider.dart # Gestion d'état des remplacements
│   └── theme_provider.dart        # Gestion du thème clair/sombre
├── screens/
│   ├── onboarding_screen.dart     # Écran d'accueil initial
│   ├── auth_screen.dart           # Connexion/Inscription
│   ├── home_screen.dart           # Écran principal avec onglets
│   ├── add_remplacement_screen.dart # Formulaire ajout/édition
│   ├── remplacement_detail_screen.dart # Détails d'un remplacement
│   ├── statistics_screen.dart     # Statistiques et graphiques
│   └── settings_screen.dart       # Paramètres et gestion du compte
├── services/
│   ├── database_service.dart      # Service Hive (local)
│   ├── supabase_service.dart      # Service Supabase (cloud)
│   └── backup_service.dart        # Import/Export JSON
├── widgets/
│   ├── glass_card.dart            # Carte avec effet de verre
│   ├── stat_card.dart             # Carte de statistique
│   └── empty_state.dart           # État vide avec illustration
└── utils/
    └── liquid_theme.dart          # Thème personnalisé avec gradients
```

---

## 🔧 Configuration

### Supabase

**Projet :** medecin-remplacant
**URL :** https://qjchhvxxrccahhtbmvcc.supabase.co
**Région :** EU (France/Allemagne)
**Anon Key :** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqY2hodnh4cmNjYWhodGJtdmNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0NjA5MDYsImV4cCI6MjA4NjAzNjkwNn0.lz-WfKqG2M08N5Uj5_uFhzpEmT_JSK6pfqDMFI_yy7k`

**Table : remplacements**
```sql
CREATE TABLE remplacements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date_debut DATE NOT NULL,
  date_fin DATE NOT NULL,
  medecin_remplace TEXT NOT NULL,
  nombre_jours REAL NOT NULL,
  taux_retrocession INTEGER NOT NULL,
  montant_avant_retrocession REAL NOT NULL,
  mode_paiement TEXT,
  date_paiement DATE,
  statut_paiement TEXT DEFAULT 'En attente',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE remplacements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own remplacements" ON remplacements
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own remplacements" ON remplacements
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own remplacements" ON remplacements
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own remplacements" ON remplacements
  FOR DELETE USING (auth.uid() = user_id);
```

**Configuration Auth :**
- Site URL : `https://pial974.github.io/medecin-remplacant/`
- Redirect URLs : `https://pial974.github.io/medecin-remplacant/**`
- Email confirmation : Activée
- Provider : Email/Password uniquement

### GitHub Pages

**Repository :** Pial974/medecin-remplacant
**Branche de déploiement :** gh-pages
**Build command :** `flutter build web --release --base-href /medecin-remplacant/`

**Important :** La branche gh-pages ne doit contenir QUE les fichiers du build web (pas de code source).

### Hive (Local Storage)

**Type Adapters :**
- Remplacement : typeId = 0
- NotificationModel : typeId = 1
- Document : typeId = 2

**Boxes :**
- remplacements
- documents
- notifications

---

## 💾 Modèle de données

### Remplacement
```dart
{
  id: String (UUID),
  dateDebut: DateTime,
  dateFin: DateTime,
  medecinRemplace: String,
  nombreJours: double,
  tauxRetrocession: int (0-100),
  montantAvantRetrocession: double,
  modePaiement: String?,
  datePaiement: DateTime?,
  statutPaiement: String ('En attente', 'Payé', 'En retard'),
  notes: String?,
  createdAt: DateTime?,
  updatedAt: DateTime?,

  // Calculs automatiques
  montantRetrocession: double (montantAvant * taux/100),
  netAvantImpots: double (montantAvant - retrocession),
  chargesUrssaf: double (netAvantImpots * 0.22),
  netApresCharges: double (netAvantImpots - charges)
}
```

---

## 🎨 Design

### Thème
- **Couleurs principales :** Indigo (#6366f1) / Violet
- **Mode sombre :** Background gradient (noir → indigo foncé)
- **Mode clair :** Background gradient (blanc → indigo très clair)
- **Effet :** Glass morphism sur les cartes
- **Typographie :** Système par défaut

### Écrans clés
1. **Onboarding** : 3 slides avec illustrations
2. **Auth** : Formulaire login/signup avec glass card
3. **Home** : 4 onglets (Remplacements, Statistiques, Documents, Notifications)
4. **Add/Edit** : Formulaire complet avec calcul en temps réel
5. **Settings** : Liste avec sections (Compte, Données, Apparence, À propos)

---

## 📋 Workflow de développement

### Build et déploiement

```bash
# Development
flutter run -d chrome

# Build web
flutter build web --release --base-href /medecin-remplacant/

# Deploy to GitHub Pages
cp -r build/web /tmp/web-deploy
git checkout gh-pages
git rm -rf .
git clean -fdx
cp -r /tmp/web-deploy/* .
rm -rf /tmp/web-deploy
git add .
git commit -m "Deploy: [message]"
git push origin gh-pages --force
git checkout main
```

### Génération des adapters Hive

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

## 🔐 Sécurité

- ✅ Row Level Security (RLS) sur Supabase
- ✅ Données utilisateur isolées (user_id dans les policies)
- ✅ Confirmation email obligatoire
- ✅ Tokens JWT gérés par Supabase
- ✅ Pas de secrets dans le code (anon key publique uniquement)
- ✅ HTTPS obligatoire (GitHub Pages)

---

## 📱 Compatibilité

### Navigateurs
- ✅ Chrome/Brave (Desktop & Mobile)
- ✅ Safari (Desktop & iOS)
- ✅ Firefox
- ✅ Edge

### Installation PWA
- ✅ iOS : Safari → Partager → Sur l'écran d'accueil
- ✅ Android : Chrome → Menu → Installer l'application
- ✅ Desktop : Chrome → Icône d'installation dans la barre d'URL

---

## 🚀 Améliorations futures possibles

### Fonctionnalités
- [ ] Export PDF des remplacements
- [ ] Graphiques avancés (évolution mensuelle, comparaisons)
- [ ] Mode multi-utilisateur / partage de cabinet
- [ ] Intégration calendrier (Google Calendar, iCal)
- [ ] Rappels push notifications (web push API)
- [ ] Calcul des impôts sur le revenu
- [ ] Gestion des frais professionnels
- [ ] Templates de contrats

### Technique
- [ ] Synchronisation en temps réel (Supabase Realtime)
- [ ] Mode offline complet avec sync queue
- [ ] Tests automatisés (unit, widget, integration)
- [ ] CI/CD automatisé (GitHub Actions)
- [ ] Monitoring et analytics
- [ ] Version mobile native (iOS/Android)

---

## 📞 Support et maintenance

**Développeur :** Claude (Anthropic)
**Owner :** Pial974
**Contact :** Via GitHub Issues

**Stack de monitoring :**
- GitHub Pages status
- Supabase dashboard pour les métriques DB
- Browser DevTools pour le debugging

---

## 📝 Notes importantes

1. **Données locales :** Stockées dans IndexedDB (Hive). Si l'utilisateur vide le cache du navigateur, les données locales seront perdues (d'où l'importance de la synchronisation cloud).

2. **Synchronisation :** Manuelle via le bouton "Synchroniser" dans les paramètres. Envoie les données locales vers le cloud, puis récupère toutes les données cloud.

3. **Mode sans compte :** Possible via "Continuer sans compte". Les données restent uniquement en local, pas de synchronisation.

4. **URSSAF :** Le taux de 22% est appliqué automatiquement. Ce taux peut varier selon la situation (ACRE, etc.), à vérifier avec un expert-comptable.

5. **GitHub Pages :** Le déploiement prend 1-2 minutes pour être visible. Toujours vider le cache après un déploiement.

6. **Supabase gratuit :** Limites du plan gratuit :
   - 500 Mo de stockage DB
   - 5 Go de bande passante
   - 50k MAU (Monthly Active Users)
   - Suffisant pour usage personnel

---

**Dernière mise à jour :** 8 février 2026
**Version :** 1.0.0
