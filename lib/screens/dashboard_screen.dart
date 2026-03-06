import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/remplacement_provider.dart';
import '../widgets/glass_card.dart';
import '../services/pdf_export_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _exportPdf(BuildContext context, RemplacementProvider provider) async {
    if (provider.remplacements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun remplacement à exporter')),
      );
      return;
    }

    try {
      await PdfExportService.exportAnnuel(
        remplacements: provider.remplacements,
        annee: provider.selectedYear,
        totalBrut: provider.totalBrut,
        totalApresRetro: provider.totalApresRetro,
        totalUrssaf: provider.totalUrssaf,
        totalNet: provider.totalNet,
        totalJours: provider.totalJours,
        tauxUrssaf: provider.tauxUrssafActuel,
        statutFiscal: provider.statutFiscalLabel,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RemplacementProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Tableau de bord'),
            actions: [
              // Bouton Export PDF
              IconButton(
                onPressed: () => _exportPdf(context, provider),
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'Exporter en PDF',
              ),
              PopupMenuButton<int>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${provider.selectedYear}'),
                    const Icon(Icons.arrow_drop_down),
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
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Alerte URSSAF si nécessaire
                      if (provider.alerteStatutFiscal != null)
                        _buildUrssafAlert(context, provider),
                      // Carte statut URSSAF
                      _buildUrssafStatusCard(context, provider),
                      const SizedBox(height: 16),
                      _buildMetricsCards(context, provider),
                      const SizedBox(height: 24),
                      _buildRevenusChart(context, provider),
                      const SizedBox(height: 16),
                      _buildPaymentStatusChart(context, provider),
                      const SizedBox(height: 16),
                      _buildMedecinStats(context, provider),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildUrssafAlert(BuildContext context, RemplacementProvider provider) {
    final isDepassement = provider.statutFiscal == StatutFiscal.depassement;
    final isMajore = provider.statutFiscal == StatutFiscal.microBNCMajore;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDepassement
              ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
              : isMajore
                  ? [const Color(0xFFF59E0B), const Color(0xFFFBBF24)]
                  : [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDepassement ? Colors.red : Colors.orange).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDepassement ? Icons.warning_rounded : Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDepassement ? 'Action requise !' : 'Information',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.alerteStatutFiscal!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrssafStatusCard(BuildContext context, RemplacementProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final prochainSeuil = provider.prochainSeuil;
    final progress = prochainSeuil != null
        ? (provider.totalBrut / prochainSeuil).clamp(0.0, 1.0)
        : 1.0;

    Color statusColor;
    switch (provider.statutFiscal) {
      case StatutFiscal.microBNC:
        statusColor = const Color(0xFF10B981);
        break;
      case StatutFiscal.microBNCMajore:
        statusColor = const Color(0xFFF59E0B);
        break;
      case StatutFiscal.depassement:
        statusColor = const Color(0xFFEF4444);
        break;
    }

    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final captionColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;

    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statut URSSAF',
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                    Text(
                      provider.statutFiscalLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Taux actuel',
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                  Text(
                    '${provider.tauxUrssafActuel}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (prochainSeuil != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progression vers ${currencyFormat.format(prochainSeuil)}',
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
                Text(
                  currencyFormat.format(provider.montantAvantProchainSeuil),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% du seuil',
              style: TextStyle(fontSize: 11, color: captionColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsCards(BuildContext context, RemplacementProvider provider) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          context,
          'Brut annuel',
          currencyFormat.format(provider.totalBrut),
          Icons.account_balance_wallet,
          Colors.blue,
        ),
        _buildMetricCard(
          context,
          'Net avant impôts',
          currencyFormat.format(provider.totalNet),
          Icons.savings,
          const Color(0xFF10B981),
        ),
        _buildMetricCard(
          context,
          'URSSAF (${provider.tauxUrssafActuel}%)',
          currencyFormat.format(provider.totalUrssaf),
          Icons.receipt_long,
          provider.statutFiscal == StatutFiscal.microBNC
              ? Colors.orange
              : const Color(0xFFEF4444),
        ),
        _buildMetricCard(
          context,
          'Jours travaillés',
          provider.totalJours.toStringAsFixed(1),
          Icons.calendar_month,
          Colors.purple,
        ),
        _buildMetricCard(
          context,
          'Revenu/jour',
          currencyFormat.format(provider.revenuMoyenParJour),
          Icons.trending_up,
          Colors.teal,
        ),
        _buildMetricCard(
          context,
          'Taux rétro. moyen',
          '${provider.tauxRetroMoyenPondere.toStringAsFixed(1)}%',
          Icons.percent,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.grey.shade900.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.6),
            border: Border.all(
              color: isDark
                  ? Colors.grey.shade700.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenusChart(BuildContext context, RemplacementProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMonth = DateTime.now().month;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final moisNoms = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];

    final Map<int, double> revenusParMois = {};
    for (final data in provider.revenusParMois) {
      final mois = int.parse(data['mois'] as String);
      final montant = (data['net'] as num?)?.toDouble() ?? 0;
      revenusParMois[mois] = montant;
    }

    final barGroups = List.generate(12, (index) {
      final mois = index + 1;
      final montant = revenusParMois[mois] ?? 0;
      final isCurrentMonth = mois == currentMonth && provider.selectedYear == DateTime.now().year;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: montant,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: isCurrentMonth
                  ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                  : [
                      const Color(0xFF6366F1).withValues(alpha: isDark ? 0.7 : 0.6),
                      const Color(0xFF818CF8).withValues(alpha: isDark ? 0.9 : 0.85),
                    ],
            ),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    });

    final maxY = barGroups.map((g) => g.barRods.first.toY).fold(0.0, (a, b) => a > b ? a : b);

    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart, color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenus mensuels nets', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('${provider.selectedYear}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  ],
                ),
              ),
              if (provider.selectedYear == DateTime.now().year)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('Mois en cours', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY * 1.25 : 1000,
                barGroups: barGroups,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? Colors.grey.shade800.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (rod.toY == 0) return null;
                      return BarTooltipItem(
                        '${moisNoms[group.x]}\n',
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        children: [
                          TextSpan(
                            text: currencyFormat.format(rod.toY),
                            style: const TextStyle(fontSize: 13, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == meta.max) return const SizedBox.shrink();
                        return Text('${(value / 1000).toStringAsFixed(0)}k', style: TextStyle(fontSize: 10, color: Colors.grey.shade500));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        final isCurrentMois = (idx + 1) == currentMonth && provider.selectedYear == DateTime.now().year;
                        return Text(
                          moisNoms[idx],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCurrentMois ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentMois ? const Color(0xFF10B981) : Colors.grey.shade500,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.grey.shade700.withValues(alpha: 0.4) : Colors.grey.shade300.withValues(alpha: 0.6),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChart(BuildContext context, RemplacementProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final nbPaye = provider.allRemplacements.where((r) => r.statutPaiement == 'Payé').length;
    final nbAttente = provider.allRemplacements.where((r) => r.statutPaiement == 'En attente').length;
    final nbRetard = provider.allRemplacements.where((r) => r.statutPaiement == 'En retard').length;
    final total = provider.allRemplacements.length;
    if (total == 0) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[
      if (nbPaye > 0) PieChartSectionData(value: nbPaye.toDouble(), color: const Color(0xFF10B981), title: '$nbPaye', radius: 45, titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      if (nbAttente > 0) PieChartSectionData(value: nbAttente.toDouble(), color: const Color(0xFFF59E0B), title: '$nbAttente', radius: 45, titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      if (nbRetard > 0) PieChartSectionData(value: nbRetard.toDouble(), color: const Color(0xFFEF4444), title: '$nbRetard', radius: 45, titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
    ];

    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.pie_chart_outline, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 10),
              const Text('État des paiements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 140, height: 140,
                child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 38, sectionsSpace: 3, pieTouchData: PieTouchData(enabled: false))),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.montantEnAttente > 0) ...[
                      Text('À encaisser', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                      Text(currencyFormat.format(provider.montantEnAttente), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                      const SizedBox(height: 12),
                    ],
                    _buildLegendItem('Payé', nbPaye, total, const Color(0xFF10B981), isDark),
                    const SizedBox(height: 8),
                    _buildLegendItem('En attente', nbAttente, total, const Color(0xFFF59E0B), isDark),
                    if (nbRetard > 0) ...[
                      const SizedBox(height: 8),
                      _buildLegendItem('En retard', nbRetard, total, const Color(0xFFEF4444), isDark),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, int total, Color color, bool isDark) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700))),
        Text('$count ($pct%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildMedecinStats(BuildContext context, RemplacementProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    if (provider.statsParMedecin.isEmpty) return const SizedBox.shrink();

    final maxNet = provider.statsParMedecin.map((s) => (s['total_net'] as num?)?.toDouble() ?? 0).fold(0.0, (a, b) => a > b ? a : b);
    final colors = [const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFF3B82F6), const Color(0xFFF59E0B), const Color(0xFFEC4899), const Color(0xFF8B5CF6)];

    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF3B82F6).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.people_outline, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Statistiques par médecin', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...provider.statsParMedecin.asMap().entries.map((entry) {
            final i = entry.key;
            final stat = entry.value;
            final medecin = stat['medecin_remplace'] as String;
            final nbRempl = stat['nb_remplacements'] as int;
            final totalJours = (stat['total_jours'] as num).toDouble();
            final tauxMoyen = (stat['taux_moyen'] as num).toDouble();
            final totalNet = (stat['total_net'] as num?)?.toDouble() ?? 0;
            final revenuJour = (stat['revenu_jour_moyen'] as num?)?.toDouble() ?? 0;
            final color = colors[i % colors.length];
            final progress = maxNet > 0 ? (totalNet / maxNet).clamp(0.0, 1.0) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.08 : 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text(medecin.isNotEmpty ? medecin[0].toUpperCase() : '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Dr $medecin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                      Text(currencyFormat.format(totalNet), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMiniStat(Icons.medical_services_outlined, '$nbRempl rempl.', isDark),
                      const SizedBox(width: 16),
                      _buildMiniStat(Icons.calendar_today_outlined, '${totalJours.toStringAsFixed(0)} j', isDark),
                      const SizedBox(width: 16),
                      _buildMiniStat(Icons.percent, '${tauxMoyen.toStringAsFixed(0)}%', isDark),
                      const SizedBox(width: 16),
                      _buildMiniStat(Icons.trending_up, '${currencyFormat.format(revenuJour)}/j', isDark),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
      ],
    );
  }
}
