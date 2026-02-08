import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmptyState extends StatefulWidget {
  final EmptyStateType type;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.type,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    final greeting = _getGreeting();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône avec effet glass
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        config.color.withValues(alpha: 0.2),
                        config.color.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: config.color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    config.icon,
                    size: 50,
                    color: config.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Salutation personnalisée
            if (_userName.isNotEmpty && widget.type == EmptyStateType.remplacements) ...[
              Text(
                '$greeting, $_userName !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // Titre
            Text(
              config.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              config.description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Bouton d'action
            if (widget.onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onAction,
                icon: Icon(config.actionIcon, size: 18),
                label: Text(widget.actionLabel ?? config.actionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: config.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],

            // Conseil du jour
            if (widget.type == EmptyStateType.remplacements) ...[
              const SizedBox(height: 32),
              _buildTip(),
            ],
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 18) {
      return 'Bon après-midi';
    } else {
      return 'Bonsoir';
    }
  }

  Widget _buildTip() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tips = [
      'Ajoutez vos remplacements dès qu\'ils sont terminés pour un suivi précis.',
      'Vérifiez régulièrement vos paiements en attente.',
      'L\'app calcule automatiquement vos cotisations URSSAF à 22%.',
      'Exportez vos données régulièrement pour vos archives.',
    ];

    final tipIndex = DateTime.now().day % tips.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: const Color(0xFF6366F1).withValues(alpha: 0.8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tips[tipIndex],
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _EmptyStateConfig _getConfig() {
    switch (widget.type) {
      case EmptyStateType.remplacements:
        return _EmptyStateConfig(
          icon: Icons.medical_services_outlined,
          title: 'Aucun remplacement',
          description: 'Commencez à suivre vos remplacements pour voir vos statistiques et revenus.',
          actionIcon: Icons.add,
          actionLabel: 'Ajouter un remplacement',
          color: const Color(0xFF6366F1),
        );
      case EmptyStateType.dashboard:
        return _EmptyStateConfig(
          icon: Icons.insights_outlined,
          title: 'Pas encore de données',
          description: 'Ajoutez des remplacements pour voir vos statistiques et graphiques.',
          actionIcon: Icons.add,
          actionLabel: 'Ajouter un remplacement',
          color: const Color(0xFF10B981),
        );
      case EmptyStateType.notifications:
        return _EmptyStateConfig(
          icon: Icons.notifications_none,
          title: 'Aucune notification',
          description: 'Vous n\'avez pas de notification pour le moment.',
          actionIcon: Icons.check,
          actionLabel: 'Tout est en ordre',
          color: Colors.orange,
        );
      case EmptyStateType.search:
        return _EmptyStateConfig(
          icon: Icons.search_off,
          title: 'Aucun résultat',
          description: 'Aucun remplacement ne correspond à votre recherche.',
          actionIcon: Icons.refresh,
          actionLabel: 'Réinitialiser',
          color: Colors.blue,
        );
    }
  }
}

enum EmptyStateType {
  remplacements,
  dashboard,
  notifications,
  search,
}

class _EmptyStateConfig {
  final IconData icon;
  final String title;
  final String description;
  final IconData actionIcon;
  final String actionLabel;
  final Color color;

  _EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionIcon,
    required this.actionLabel,
    required this.color,
  });
}
