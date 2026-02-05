import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/remplacement.dart';

class PdfExportService {
  static Future<void> exportAnnuel({
    required List<Remplacement> remplacements,
    required int annee,
    required double totalBrut,
    required double totalApresRetro,
    required double totalUrssaf,
    required double totalNet,
    required double totalJours,
    required double tauxUrssaf,
    required String statutFiscal,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    // Récupérer le nom de l'utilisateur
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? 'Médecin Remplaçant';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(userName, annee),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Résumé
          _buildSummarySection(
            totalBrut: totalBrut,
            totalApresRetro: totalApresRetro,
            totalUrssaf: totalUrssaf,
            totalNet: totalNet,
            totalJours: totalJours,
            tauxUrssaf: tauxUrssaf,
            statutFiscal: statutFiscal,
            currencyFormat: currencyFormat,
          ),
          pw.SizedBox(height: 20),

          // Tableau des remplacements
          _buildRemplacementsTable(remplacements, dateFormat, currencyFormat),

          pw.SizedBox(height: 20),

          // Totaux
          _buildTotauxSection(
            totalBrut: totalBrut,
            totalNet: totalNet,
            totalJours: totalJours,
            nbRemplacements: remplacements.length,
            currencyFormat: currencyFormat,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Remplacements_$annee.pdf',
    );
  }

  static pw.Widget _buildHeader(String userName, int annee) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1, color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                userName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Récapitulatif des remplacements',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.indigo50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'Année $annee',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.5, color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
          pw.Text(
            'Page ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection({
    required double totalBrut,
    required double totalApresRetro,
    required double totalUrssaf,
    required double totalNet,
    required double totalJours,
    required double tauxUrssaf,
    required String statutFiscal,
    required NumberFormat currencyFormat,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Résumé annuel',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Statut fiscal', statutFiscal),
              _buildSummaryItem('Taux URSSAF', '$tauxUrssaf%'),
              _buildSummaryItem('Jours travaillés', totalJours.toStringAsFixed(1)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Total brut', currencyFormat.format(totalBrut)),
              _buildSummaryItem('URSSAF', currencyFormat.format(totalUrssaf)),
              _buildSummaryItem('Net avant impôts', currencyFormat.format(totalNet), highlight: true),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, {bool highlight = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: highlight ? 12 : 11,
            fontWeight: highlight ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: highlight ? PdfColors.green700 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRemplacementsTable(
    List<Remplacement> remplacements,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.indigo,
      ),
      headerHeight: 30,
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellHeight: 28,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.center,
      },
      headers: [
        'Médecin',
        'Début',
        'Fin',
        'Jours',
        'Brut',
        'Net',
        'Statut',
      ],
      data: remplacements.map((r) {
        return [
          'Dr ${r.medecinRemplace}',
          dateFormat.format(r.dateDebut),
          dateFormat.format(r.dateFin),
          r.nombreJours.toStringAsFixed(1),
          currencyFormat.format(r.montantAvantRetrocession),
          currencyFormat.format(r.netAvantImpots),
          r.statutPaiement,
        ];
      }).toList(),
      oddRowDecoration: const pw.BoxDecoration(
        color: PdfColors.grey50,
      ),
    );
  }

  static pw.Widget _buildTotauxSection({
    required double totalBrut,
    required double totalNet,
    required double totalJours,
    required int nbRemplacements,
    required NumberFormat currencyFormat,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.indigo, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildTotalItem('Remplacements', '$nbRemplacements'),
          _buildTotalItem('Jours', totalJours.toStringAsFixed(1)),
          _buildTotalItem('Total Brut', currencyFormat.format(totalBrut)),
          _buildTotalItem('Total Net', currencyFormat.format(totalNet), isMain: true),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalItem(String label, String value, {bool isMain = false}) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isMain ? 16 : 14,
            fontWeight: pw.FontWeight.bold,
            color: isMain ? PdfColors.green700 : PdfColors.indigo,
          ),
        ),
      ],
    );
  }
}
