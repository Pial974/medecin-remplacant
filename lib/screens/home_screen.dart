import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/remplacement_provider.dart';
import '../models/remplacement.dart';
import '../widgets/glass_card.dart';
import '../widgets/empty_state.dart';
import '../main.dart';
import 'add_remplacement_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemplacementProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _RemplacementsTab(),
          LiquidBackground(child: DashboardScreen()),
          LiquidBackground(child: SettingsScreen()),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Remplacements',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Analyse',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Paramètres',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LiquidBackground(
                      child: AddRemplacementScreen(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouveau'),
            )
          : null,
    );
  }
}

class _RemplacementsTab extends StatefulWidget {
  const _RemplacementsTab();

  @override
  State<_RemplacementsTab> createState() => _RemplacementsTabState();
}

class _RemplacementsTabState extends State<_RemplacementsTab> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Consumer<RemplacementProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: _showSearch
                ? _buildSearchField(provider)
                : const Text('Mes Remplacements'),
            actions: [
              IconButton(
                icon: Icon(_showSearch ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchController.clear();
                      provider.setSearchQuery('');
                    }
                  });
                },
              ),
              if (!_showSearch) _buildYearSelector(context, provider),
              if (!_showSearch && provider.notifications.isNotEmpty)
                _buildNotificationBadge(context, provider),
            ],
          ),
          body: Column(
            children: [
              _buildSummaryCard(context, provider, currencyFormat),
              // Filtres
              _buildFilterChips(context, provider),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.remplacements.isEmpty
                        ? _buildEmptyState(context, provider)
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: provider.remplacements.length,
                            itemBuilder: (context, index) {
                              final r = provider.remplacements[index];
                              return _buildRemplacementCard(
                                  context, r, currencyFormat, provider);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField(RemplacementProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Rechercher un médecin...',
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: (value) => provider.setSearchQuery(value),
    );
  }

  Widget _buildFilterChips(BuildContext context, RemplacementProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!provider.hasActiveFilters && provider.allRemplacements.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Bouton réinitialiser si filtres actifs
          if (provider.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Icons.clear, size: 16),
                label: const Text('Réinitialiser'),
                onPressed: () => provider.clearFilters(),
              ),
            ),
          // Filtres par statut
          _buildFilterChip(
            context,
            label: 'Tous',
            isSelected: provider.filterStatut == null,
            onSelected: (_) => provider.setFilterStatut(null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Payé',
            isSelected: provider.filterStatut == 'Payé',
            color: const Color(0xFF10B981),
            onSelected: (_) => provider.setFilterStatut(
                provider.filterStatut == 'Payé' ? null : 'Payé'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'En attente',
            isSelected: provider.filterStatut == 'En attente',
            color: const Color(0xFFF59E0B),
            onSelected: (_) => provider.setFilterStatut(
                provider.filterStatut == 'En attente' ? null : 'En attente'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'En retard',
            isSelected: provider.filterStatut == 'En retard',
            color: const Color(0xFFEF4444),
            onSelected: (_) => provider.setFilterStatut(
                provider.filterStatut == 'En retard' ? null : 'En retard'),
          ),
          // Séparateur si médecins disponibles
          if (provider.medecins.isNotEmpty) ...[
            const SizedBox(width: 16),
            Container(
              height: 24,
              width: 1,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(width: 16),
            // Filtre par médecin
            PopupMenuButton<String?>(
              child: Chip(
                avatar: const Icon(Icons.person, size: 16),
                label: Text(provider.filterMedecin ?? 'Médecin'),
                backgroundColor: provider.filterMedecin != null
                    ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                    : null,
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: null,
                  child: Text('Tous les médecins'),
                ),
                ...provider.medecins.map((m) => PopupMenuItem(
                      value: m,
                      child: Text('Dr $m'),
                    )),
              ],
              onSelected: (value) => provider.setFilterMedecin(value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    Color? color,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: color?.withValues(alpha: 0.2) ?? const Color(0xFF6366F1).withValues(alpha: 0.2),
      checkmarkColor: color ?? const Color(0xFF6366F1),
      side: isSelected && color != null
          ? BorderSide(color: color.withValues(alpha: 0.5))
          : null,
    );
  }

  Widget _buildYearSelector(BuildContext context, RemplacementProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade800.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.grey.shade700.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: PopupMenuButton<int>(
              offset: const Offset(0, 40),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${provider.selectedYear}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
              onSelected: (year) => provider.setYear(year),
              itemBuilder: (context) {
                final currentYear = DateTime.now().year;
                return List.generate(5, (index) {
                  final year = currentYear - index;
                  return PopupMenuItem(value: year, child: Text('$year'));
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(
      BuildContext context, RemplacementProvider provider) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showNotifications(context, provider),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${provider.notifications.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, RemplacementProvider provider,
      NumberFormat currencyFormat) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Net total',
                currencyFormat.format(provider.totalNet),
                const Color(0xFF10B981),
                Icons.account_balance_wallet,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                context,
                'Jours',
                provider.totalJours.toStringAsFixed(1),
                const Color(0xFF3B82F6),
                Icons.calendar_today,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                context,
                '/jour',
                currencyFormat.format(provider.revenuMoyenParJour),
                const Color(0xFFF59E0B),
                Icons.trending_up,
              ),
            ],
          ),
          if (provider.nbEnAttente > 0 || provider.nbEnRetard > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (provider.nbEnAttente > 0)
                    GlassChip(
                      label: '${provider.nbEnAttente} en attente',
                      color: Colors.orange,
                      icon: Icons.schedule,
                    ),
                  if (provider.nbEnAttente > 0 && provider.nbEnRetard > 0)
                    const SizedBox(width: 8),
                  if (provider.nbEnRetard > 0)
                    GlassChip(
                      label: '${provider.nbEnRetard} en retard',
                      color: Colors.red,
                      icon: Icons.warning_amber,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, RemplacementProvider provider) {
    // Si des filtres sont actifs mais aucun résultat
    if (provider.hasActiveFilters) {
      return EmptyState(
        type: EmptyStateType.search,
        onAction: () => provider.clearFilters(),
        actionLabel: 'Réinitialiser les filtres',
      );
    }

    // Pas de remplacements du tout
    return EmptyState(
      type: EmptyStateType.remplacements,
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LiquidBackground(
              child: AddRemplacementScreen(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRemplacementCard(BuildContext context, Remplacement r,
      NumberFormat currencyFormat, RemplacementProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM', 'fr_FR');
    final statusColor = switch (r.statutPaiement) {
      'Payé' => const Color(0xFF10B981),
      'En retard' => const Color(0xFFEF4444),
      _ => const Color(0xFFF59E0B),
    };
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              r.statutPaiement == 'Payé'
                  ? Icons.check_circle
                  : r.statutPaiement == 'En retard'
                      ? Icons.error
                      : Icons.schedule,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr ${r.medecinRemplace}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 12, color: subtitleColor),
                    const SizedBox(width: 4),
                    Text(
                      '${dateFormat.format(r.dateDebut)} - ${dateFormat.format(r.dateFin)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${r.nombreJours}j',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(r.netAvantImpots),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF10B981),
                ),
              ),
              Text(
                '${r.tauxRetrocession}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          // Menu
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Modifier')),
              if (r.statutPaiement != 'Payé')
                const PopupMenuItem(value: 'pay', child: Text('Marquer payé')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiquidBackground(
                        child: AddRemplacementScreen(remplacement: r),
                      ),
                    ),
                  );
                  break;
                case 'pay':
                  await provider.marquerCommePaye(r);
                  break;
                case 'delete':
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirmer la suppression'),
                      content: const Text('Supprimer ce remplacement ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Supprimer',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && r.id != null) {
                    await provider.deleteRemplacement(r.id!);
                  }
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  void _showNotifications(
      BuildContext context, RemplacementProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade900.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final n = provider.notifications[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber, color: Colors.orange),
                  ),
                  title: Text(n.titre),
                  subtitle: Text(n.message),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.green),
                    onPressed: () {
                      provider.traiterNotification(n.id!);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
