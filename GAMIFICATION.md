# 🎮 Gamification - Évolution Future

Document de conception pour l'ajout d'éléments de gamification à l'application Médecin Remplaçant.

---

## 🎯 Objectifs

Rendre l'application plus engageante et motivante en ajoutant des mécaniques de jeu qui encouragent :
- L'utilisation régulière de l'application
- Le suivi rigoureux des remplacements
- La bonne gestion des paiements
- L'organisation financière

---

## 🏆 Système de points et niveaux

### Points d'expérience (XP)

**Actions récompensées :**
| Action | Points | Fréquence |
|--------|--------|-----------|
| Ajouter un remplacement | +10 XP | Illimité |
| Marquer un paiement comme payé | +15 XP | Illimité |
| Synchroniser avec le cloud | +5 XP | 1x/jour max |
| Streak de 7 jours | +50 XP | Hebdomadaire |
| Streak de 30 jours | +200 XP | Mensuel |
| Atteindre objectif mensuel | +100 XP | Mensuel |
| Tous paiements à jour | +25 XP | 1x/semaine max |
| Exporter les données | +10 XP | Illimité |

### Niveaux

```
Niveau 1: 🌱 Remplaçant Débutant (0-100 XP)
Niveau 2: 📈 Remplaçant Confirmé (101-500 XP)
Niveau 3: 🎯 Remplaçant Expert (501-1500 XP)
Niveau 4: 💎 Remplaçant Maître (1501-3000 XP)
Niveau 5: 👑 Légende du Remplacement (3000+ XP)
```

**Avantages par niveau :**
- Niveau 2 : Débloquer thèmes supplémentaires
- Niveau 3 : Débloquer graphiques avancés
- Niveau 4 : Débloquer comparaisons historiques
- Niveau 5 : Débloquer mode "Dark Premium" + tous les thèmes

---

## 🏅 Badges (Achievements)

### Catégorie : Débuts

| Badge | Icône | Condition | Points |
|-------|-------|-----------|--------|
| **Premier pas** | 🎯 | Ajouter votre 1er remplacement | +20 XP |
| **Bonne habitude** | ✅ | Ajouter 5 remplacements | +30 XP |
| **Pro actif** | 🚀 | Ajouter 10 remplacements | +50 XP |

### Catégorie : Revenus

| Badge | Icône | Condition | Points |
|-------|-------|-----------|--------|
| **Premiers gains** | 💵 | Atteindre 1 000€ de revenus | +30 XP |
| **En bonne voie** | 💰 | Atteindre 5 000€ de revenus | +50 XP |
| **Millionnaire** | 💎 | Atteindre 10 000€ de revenus | +100 XP |
| **Fortune** | 👑 | Atteindre 50 000€ de revenus | +200 XP |

### Catégorie : Organisation

| Badge | Icône | Condition | Points |
|-------|-------|-----------|--------|
| **Organisé** | 📋 | Tous les paiements à jour (1 fois) | +40 XP |
| **Maître de l'ordre** | ⭐ | Tous paiements à jour 5 fois | +100 XP |
| **Zéro retard** | 🎖️ | Aucun paiement en retard pendant 3 mois | +150 XP |
| **Archiviste** | 📚 | Exporter les données 5 fois | +50 XP |

### Catégorie : Activité

| Badge | Icône | Condition | Points |
|-------|-------|-----------|--------|
| **Semaine complète** | 📅 | 5 remplacements en une semaine | +60 XP |
| **Mois productif** | 🗓️ | 20 jours de remplacement en un mois | +100 XP |
| **Marathon** | 🏃 | 30 remplacements en un mois | +150 XP |
| **Infatigable** | 💪 | 50 remplacements au total | +200 XP |

### Catégorie : Engagement

| Badge | Icône | Condition | Points |
|-------|-------|-----------|--------|
| **Régulier** | 🔥 | Utiliser l'app 7 jours d'affilée | +50 XP |
| **Dévoué** | ⚡ | Utiliser l'app 30 jours d'affilée | +150 XP |
| **Légende** | 👑 | Utiliser l'app 100 jours d'affilée | +500 XP |

### Catégorie : Expertise

| Badge | Icône | Condition | Points |
|-------|-------|-----------|--------|
| **Apprenti URSSAF** | 📊 | Consulter ses charges 10 fois | +30 XP |
| **Expert URSSAF** | 🎓 | Comprendre le calcul des 22% | +60 XP |
| **Analyste** | 📈 | Consulter les stats 50 fois | +80 XP |
| **Data Master** | 🤓 | Utiliser tous les filtres disponibles | +70 XP |

### Catégorie : Cloud

| Badge | Icône | Condition | Points |
|-------|-------|-----------|--------|
| **Connecté** | 🌐 | Se connecter avec un compte | +20 XP |
| **Synchronisé** | 🔄 | Synchroniser 1 fois | +20 XP |
| **Maître de la sync** | 💫 | Synchroniser 20 fois | +100 XP |
| **Cloud addict** | ☁️ | Synchroniser 100 fois | +200 XP |

### Catégorie : Performance

| Badge | Icône | Condition | Points |
|-------|-------|-----------|--------|
| **En croissance** | 📈 | +50% de revenus vs mois précédent | +80 XP |
| **Record battu** | 🏆 | Meilleur mois de revenus | +100 XP |
| **Efficace** | ⚡ | Revenu/jour > 300€ | +60 XP |

---

## 🎯 Challenges quotidiens/hebdomadaires

### Challenges quotidiens

**Rotation automatique, 1 challenge actif par jour :**

| Challenge | Objectif | Récompense |
|-----------|----------|------------|
| **Journée productive** | Ajouter 1 remplacement aujourd'hui | +20 XP |
| **Mise à jour** | Synchroniser vos données | +15 XP |
| **Vérification** | Consulter vos statistiques | +10 XP |
| **Organisation** | Marquer 1 paiement comme payé | +20 XP |

### Challenges hebdomadaires

**1 challenge actif par semaine (lundi-dimanche) :**

| Challenge | Objectif | Récompense |
|-----------|----------|------------|
| **Semaine chargée** | Ajouter 3 remplacements cette semaine | +60 XP |
| **Tout en ordre** | Marquer tous les paiements en retard | +80 XP |
| **Régularité** | Utiliser l'app 5 jours cette semaine | +50 XP |
| **Archivage** | Exporter vos données 1 fois | +40 XP |

### Challenges mensuels

**1 challenge actif par mois :**

| Challenge | Objectif | Récompense |
|-----------|----------|------------|
| **Objectif revenus** | Atteindre 3000€ ce mois-ci | +150 XP |
| **Mois complet** | 15 remplacements ce mois | +200 XP |
| **Maître sync** | Synchroniser 10 fois ce mois | +100 XP |
| **Sans faute** | Aucun paiement en retard ce mois | +120 XP |

---

## 📊 Barres de progression

### 1. Progression vers le niveau suivant

```dart
// Affichage en haut de l'écran profil
LinearProgressIndicator(
  value: (currentXP - levelMinXP) / (levelMaxXP - levelMinXP),
  backgroundColor: Colors.grey.shade300,
  color: Color(0xFF6366F1),
)

// Exemple : Niveau 2 (250 XP / 500 XP requis) = 50%
```

### 2. Objectif mensuel de revenus

```dart
// Défini par l'utilisateur ou calculé automatiquement
// Basé sur la moyenne des 3 derniers mois
CircularProgressIndicator(
  value: actualRevenue / targetRevenue,
  strokeWidth: 12,
)

// Exemple : 2500€ / 3000€ = 83%
```

### 3. Completion des badges

```dart
// X badges débloqués sur Y total
Text('${unlockedBadges} / ${totalBadges} badges')

// Grid montrant tous les badges
// Locked = noir et blanc
// Unlocked = couleur + effet glow
```

### 4. Streak actuel

```dart
// Jours consécutifs d'utilisation
Row(
  children: [
    Icon(Icons.local_fire_department, color: Colors.orange),
    Text('${currentStreak} jours'),
  ],
)
```

---

## 🎉 Animations et effets

### 1. Confettis

**Quand déclencher :**
- Nouveau badge débloqué
- Niveau up
- Challenge complété

**Implémentation :**
```dart
// Package : confetti
ConfettiWidget(
  blastDirectionality: BlastDirectionality.explosive,
  colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
  numberOfParticles: 30,
  gravity: 0.3,
)
```

### 2. Animation de niveau up

```dart
// Modal animé avec:
AnimatedContainer(
  duration: Duration(milliseconds: 500),
  curve: Curves.elasticOut,
  transform: Matrix4.identity()..scale(scale),
  child: Column(
    children: [
      Icon(Icons.stars, size: 100, color: Colors.amber),
      Text('NIVEAU ${newLevel}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      Text('Nouveau niveau atteint !'),
    ],
  ),
)
```

### 3. Badge unlock animation

```dart
// Badge qui apparaît avec rotation + scale
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.rotate(
      angle: _rotationAnimation.value,
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Icon(badge.icon, size: 80, color: badge.color),
      ),
    );
  },
)
```

### 4. Particle effects

```dart
// Petites étoiles qui montent lors d'un gain de XP
// Package : flutter_particles
Particles(
  number: 20,
  color: Colors.amber,
  direction: ParticleDirection.up,
)
```

---

## 🎨 Récompenses déblocables

### Thèmes

**Déblocables avec les niveaux :**

| Thème | Niveau requis | Couleurs principales |
|-------|---------------|---------------------|
| **Indigo** (défaut) | 1 | #6366F1, #818CF8 |
| **Émeraude** | 2 | #10B981, #34D399 |
| **Sunset** | 3 | #F59E0B, #EF4444 |
| **Ocean** | 3 | #0EA5E9, #06B6D4 |
| **Purple Dream** | 4 | #A855F7, #C084FC |
| **Dark Premium** | 5 | Dégradés avancés |

### Icônes d'app personnalisées

**Déblocables avec XP :**
- 500 XP : Icône verte
- 1000 XP : Icône orange
- 2000 XP : Icône violette
- 3000 XP : Icône dorée

### Fonctionnalités

**Déblocables progressivement :**
- Niveau 2 : Comparaison mois vs mois
- Niveau 3 : Graphiques détaillés (camembert, courbes)
- Niveau 4 : Export PDF premium avec logo
- Niveau 5 : Prédictions basées sur l'historique

---

## 💻 Implémentation technique

### 1. Modèle de données

```dart
@HiveType(typeId: 3)
class GameProfile extends HiveObject {
  @HiveField(0)
  int totalXP;

  @HiveField(1)
  int level;

  @HiveField(2)
  List<String> unlockedBadges;

  @HiveField(3)
  int currentStreak;

  @HiveField(4)
  DateTime? lastActiveDate;

  @HiveField(5)
  String? activeDailyChallenge;

  @HiveField(6)
  String? activeWeeklyChallenge;

  @HiveField(7)
  Map<String, int> challengeProgress; // {"daily_add_1": 1/1}

  @HiveField(8)
  DateTime? weeklyChalleneStartDate;

  // Méthodes
  int get currentLevel => _calculateLevel(totalXP);
  int get xpForNextLevel => _getXPForLevel(currentLevel + 1);
  double get progressToNextLevel =>
    (totalXP - _getXPForLevel(currentLevel)) /
    (_getXPForLevel(currentLevel + 1) - _getXPForLevel(currentLevel));

  static int _calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 500) return 2;
    if (xp < 1500) return 3;
    if (xp < 3000) return 4;
    return 5;
  }

  static int _getXPForLevel(int level) {
    switch (level) {
      case 1: return 0;
      case 2: return 100;
      case 3: return 500;
      case 4: return 1500;
      case 5: return 3000;
      default: return 3000;
    }
  }
}
```

### 2. Modèle Badge

```dart
class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final BadgeCategory category;
  final int xpReward;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.xpReward,
  });

  // Vérifier si le badge doit être débloqué
  bool checkUnlock(GameProfile profile, RemplacementProvider provider) {
    switch (id) {
      case 'first_remplacement':
        return provider.allRemplacements.isNotEmpty;
      case 'millionaire':
        return provider.totalRevenu >= 10000;
      case 'week_complete':
        // Vérifier si 5 remplacements dans les 7 derniers jours
        final now = DateTime.now();
        final weekAgo = now.subtract(Duration(days: 7));
        final thisWeek = provider.allRemplacements
            .where((r) => r.createdAt!.isAfter(weekAgo))
            .length;
        return thisWeek >= 5;
      // ... autres conditions
      default:
        return false;
    }
  }
}

enum BadgeCategory {
  debuts,
  revenus,
  organisation,
  activite,
  engagement,
  expertise,
  cloud,
  performance,
}
```

### 3. Service de Gamification

```dart
class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  late Box<GameProfile> _profileBox;

  Future<void> init() async {
    _profileBox = await Hive.openBox<GameProfile>('game_profile');
    if (_profileBox.isEmpty) {
      final profile = GameProfile()
        ..totalXP = 0
        ..level = 1
        ..unlockedBadges = []
        ..currentStreak = 0;
      await _profileBox.add(profile);
    }
  }

  GameProfile get profile => _profileBox.values.first;

  // Ajouter des XP
  Future<LevelUpResult> addXP(int xp, String reason) async {
    final oldLevel = profile.currentLevel;
    profile.totalXP += xp;
    await profile.save();

    final newLevel = profile.currentLevel;
    final leveledUp = newLevel > oldLevel;

    return LevelUpResult(
      xpGained: xp,
      leveledUp: leveledUp,
      newLevel: newLevel,
      reason: reason,
    );
  }

  // Vérifier et débloquer les badges
  Future<List<Badge>> checkAndUnlockBadges(RemplacementProvider provider) async {
    final newlyUnlocked = <Badge>[];

    for (final badge in allBadges) {
      if (!profile.unlockedBadges.contains(badge.id)) {
        if (badge.checkUnlock(profile, provider)) {
          profile.unlockedBadges.add(badge.id);
          await profile.save();
          await addXP(badge.xpReward, 'Badge: ${badge.name}');
          newlyUnlocked.add(badge);
        }
      }
    }

    return newlyUnlocked;
  }

  // Mettre à jour le streak
  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (profile.lastActiveDate == null) {
      profile.currentStreak = 1;
      profile.lastActiveDate = today;
    } else {
      final lastDate = DateTime(
        profile.lastActiveDate!.year,
        profile.lastActiveDate!.month,
        profile.lastActiveDate!.day,
      );
      final diff = today.difference(lastDate).inDays;

      if (diff == 0) {
        // Même jour, rien à faire
      } else if (diff == 1) {
        // Jour consécutif
        profile.currentStreak++;
        profile.lastActiveDate = today;

        // Récompense pour streak
        if (profile.currentStreak == 7) {
          await addXP(50, 'Streak de 7 jours');
        } else if (profile.currentStreak == 30) {
          await addXP(200, 'Streak de 30 jours');
        }
      } else {
        // Streak cassé
        profile.currentStreak = 1;
        profile.lastActiveDate = today;
      }
    }

    await profile.save();
  }
}

class LevelUpResult {
  final int xpGained;
  final bool leveledUp;
  final int newLevel;
  final String reason;

  LevelUpResult({
    required this.xpGained,
    required this.leveledUp,
    required this.newLevel,
    required this.reason,
  });
}
```

### 4. Nouveaux écrans

```dart
// 1. GameProfileScreen - Profil de jeu
class GameProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = GamificationService().profile;

    return Scaffold(
      appBar: AppBar(title: Text('Profil de Jeu')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Carte de niveau
          _buildLevelCard(profile),

          SizedBox(height: 16),

          // Streak
          _buildStreakCard(profile),

          SizedBox(height: 16),

          // Progression vers niveau suivant
          _buildProgressCard(profile),

          SizedBox(height: 24),

          // Badges récents
          Text('Badges récents', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 8),
          _buildRecentBadges(profile),

          SizedBox(height: 24),

          // Bouton voir tous les badges
          ElevatedButton.icon(
            onPressed: () => Navigator.push(...),
            icon: Icon(Icons.emoji_events),
            label: Text('Voir tous les badges (${profile.unlockedBadges.length}/${allBadges.length})'),
          ),

          SizedBox(height: 24),

          // Stats
          Text('Statistiques', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 8),
          _buildStats(profile),
        ],
      ),
    );
  }
}

// 2. AchievementsScreen - Tous les badges
class AchievementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = GamificationService().profile;

    return Scaffold(
      appBar: AppBar(title: Text('Achievements')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: BadgeCategory.values.length,
        itemBuilder: (context, index) {
          final category = BadgeCategory.values[index];
          final categoryBadges = allBadges.where((b) => b.category == category).toList();

          return _buildCategorySection(category, categoryBadges, profile);
        },
      ),
    );
  }

  Widget _buildCategorySection(BadgeCategory category, List<Badge> badges, GameProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(categoryName(category), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final unlocked = profile.unlockedBadges.contains(badge.id);
            return _buildBadgeCard(badge, unlocked);
          },
        ),
        SizedBox(height: 24),
      ],
    );
  }
}

// 3. ChallengesScreen - Défis actifs
class ChallengesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Challenges')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Challenge quotidien
          _buildDailyChallengeCard(),

          SizedBox(height: 16),

          // Challenge hebdomadaire
          _buildWeeklyChallengeCard(),

          SizedBox(height: 16),

          // Challenge mensuel
          _buildMonthlyChallengeCard(),
        ],
      ),
    );
  }
}
```

### 5. Intégration dans l'app existante

**Modifications à faire :**

```dart
// 1. Ajouter un 4ème onglet dans home_screen.dart
NavigationDestination(
  icon: Icon(Icons.emoji_events_outlined),
  selectedIcon: Icon(Icons.emoji_events),
  label: 'Profil',
),

// 2. Appeler updateStreak() au lancement de l'app
void main() async {
  // ...
  await GamificationService().init();
  await GamificationService().updateStreak();
  runApp(const MyApp());
}

// 3. Ajouter XP lors des actions
// Dans RemplacementProvider.addRemplacement()
await GamificationService().addXP(10, 'Remplacement ajouté');
final badges = await GamificationService().checkAndUnlockBadges(this);
if (badges.isNotEmpty) {
  _showBadgeUnlockedModal(badges.first);
}

// 4. Afficher niveau dans l'AppBar
Widget _buildLevelBadge() {
  final profile = GamificationService().profile;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.amber,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.stars, size: 14, color: Colors.white),
        SizedBox(width: 4),
        Text('Niv. ${profile.level}', style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );
}
```

---

## 📦 Packages recommandés

```yaml
dependencies:
  confetti: ^0.7.0  # Animations de confettis
  flutter_animate: ^4.5.0  # Animations fluides
  shimmer: ^3.0.0  # Effet shimmer sur badges
  lottie: ^3.1.2  # Animations Lottie (optionnel)
```

---

## 🚀 Plan de déploiement

### Phase 1 : Infrastructure (3-4 jours)
- ✅ Créer GameProfile model + Hive adapter
- ✅ Créer Badge model
- ✅ Créer GamificationService
- ✅ Définir tous les badges (20+)
- ✅ Implémenter système de XP
- ✅ Implémenter calcul de niveau

### Phase 2 : UI de base (3-4 jours)
- ✅ Créer GameProfileScreen
- ✅ Créer AchievementsScreen
- ✅ Ajouter 4ème onglet
- ✅ Afficher niveau dans AppBar
- ✅ Afficher streak

### Phase 3 : Intégration (2-3 jours)
- ✅ Attribuer XP lors des actions
- ✅ Vérifier badges après chaque action
- ✅ Mettre à jour streak quotidiennement
- ✅ Sauvegarder dans Hive

### Phase 4 : Animations (2-3 jours)
- ✅ Modal de badge débloqué avec confettis
- ✅ Animation de level up
- ✅ Effets visuels sur badges unlocked
- ✅ Transitions fluides

### Phase 5 : Challenges (2-3 jours)
- ✅ Système de challenges quotidiens
- ✅ Système de challenges hebdomadaires
- ✅ Système de challenges mensuels
- ✅ ChallengesScreen
- ✅ Notifications de challenges

### Phase 6 : Récompenses (2-3 jours)
- ✅ Thèmes déblocables
- ✅ Icônes déblocables
- ✅ Fonctionnalités déblocables
- ✅ Interface de sélection

### Phase 7 : Polish & Tests (2-3 jours)
- ✅ Tests unitaires
- ✅ Tests d'intégration
- ✅ Optimisations performances
- ✅ Documentation

**Durée totale estimée : 3-4 semaines**

---

## 📊 Métriques de succès

Pour mesurer l'impact de la gamification :

- **Engagement** : Augmentation de la fréquence d'utilisation
- **Rétention** : Augmentation du streak moyen
- **Complétude** : Plus de remplacements ajoutés régulièrement
- **Organisation** : Moins de paiements en retard
- **Satisfaction** : Feedback utilisateurs positif

---

## ⚠️ Points d'attention

### À éviter :
- ❌ Trop de notifications (risque de spam)
- ❌ XP trop faciles à gagner (perte de valeur)
- ❌ Trop de badges (dilution de la valeur)
- ❌ Animations trop longues (frustration)

### Bonnes pratiques :
- ✅ Équilibrer difficulté et récompenses
- ✅ Animations rapides et smooth
- ✅ Badges significatifs et mémorables
- ✅ Progression claire et motivante
- ✅ Option pour désactiver la gamification

---

## 🎯 Conclusion

La gamification transformera l'application en une expérience plus engageante et motivante, encourageant les utilisateurs à mieux gérer leurs remplacements tout en s'amusant.

**Bénéfices attendus :**
- 📈 +40% d'utilisation régulière
- 🎯 +30% de complétion des profils
- ⚡ +50% d'engagement
- 😊 Satisfaction utilisateur accrue

---

**Document créé le :** 8 février 2026
**Dernière mise à jour :** 8 février 2026
**Statut :** 📋 Planifié (non implémenté)
