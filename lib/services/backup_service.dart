import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/remplacement.dart';
import 'database_service.dart';

class BackupService {
  static final DatabaseService _db = DatabaseService();

  /// Exporte toutes les données en JSON et partage le fichier
  static Future<bool> exportData() async {
    try {
      // Utiliser la méthode d'export du DatabaseService
      final backupData = await _db.exportAllData();

      // Convertir en JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      if (kIsWeb) {
        // Pour le web, télécharger directement
        // Note: Le téléchargement web sera géré différemment
        return false;
      }

      // Créer le fichier temporaire
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/medecin_remplacant_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      // Partager le fichier
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Sauvegarde Médecin Remplaçant',
          text: 'Sauvegarde de mes données de remplacements',
        ),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Importe les données depuis un fichier JSON
  static Future<ImportResult> importData() async {
    try {
      // Sélectionner le fichier
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb, // Nécessaire pour le web
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'Aucun fichier sélectionné');
      }

      String jsonString;

      if (kIsWeb) {
        // Sur le web, lire les bytes directement
        final bytes = result.files.single.bytes;
        if (bytes == null) {
          return ImportResult(success: false, message: 'Impossible de lire le fichier');
        }
        jsonString = utf8.decode(bytes);
      } else {
        final file = File(result.files.single.path!);
        jsonString = await file.readAsString();
      }

      // Parser le JSON
      final Map<String, dynamic> backupData = json.decode(jsonString);

      // Vérifier la version (supporte v1 et v2)
      final version = backupData['version'];
      final versionNum = version is String ? double.tryParse(version)?.toInt() : version as int?;

      if (versionNum == null || versionNum > 2) {
        return ImportResult(
          success: false,
          message: 'Format de fichier non supporté',
        );
      }

      // Récupérer les remplacements
      final remplacementsList = backupData['remplacements'] as List<dynamic>?;
      if (remplacementsList == null) {
        return ImportResult(
          success: false,
          message: 'Fichier de sauvegarde invalide',
        );
      }

      // Importer les remplacements
      int imported = 0;
      int skipped = 0;

      for (final item in remplacementsList) {
        try {
          final map = Map<String, dynamic>.from(item);
          // Supprimer l'ID pour créer de nouveaux enregistrements
          map.remove('id');
          final remplacement = Remplacement.fromMap(map);
          await _db.insertRemplacement(remplacement);
          imported++;
        } catch (e) {
          skipped++;
        }
      }

      return ImportResult(
        success: true,
        message: '$imported remplacement(s) importé(s)',
        importedCount: imported,
        skippedCount: skipped,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Erreur lors de l\'import: ${e.toString()}',
      );
    }
  }

  /// Exporte et remplace toutes les données (restauration complète)
  static Future<ImportResult> restoreData() async {
    try {
      // Sélectionner le fichier
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'Aucun fichier sélectionné');
      }

      String jsonString;

      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes == null) {
          return ImportResult(success: false, message: 'Impossible de lire le fichier');
        }
        jsonString = utf8.decode(bytes);
      } else {
        final file = File(result.files.single.path!);
        jsonString = await file.readAsString();
      }

      // Parser le JSON
      final Map<String, dynamic> backupData = json.decode(jsonString);

      // Utiliser la méthode d'import du DatabaseService qui remplace tout
      await _db.importAllData(backupData);

      final remplacementsList = backupData['remplacements'] as List<dynamic>? ?? [];

      return ImportResult(
        success: true,
        message: '${remplacementsList.length} remplacement(s) restauré(s)',
        importedCount: remplacementsList.length,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Erreur lors de la restauration: ${e.toString()}',
      );
    }
  }
}

class ImportResult {
  final bool success;
  final String message;
  final int importedCount;
  final int skippedCount;

  ImportResult({
    required this.success,
    required this.message,
    this.importedCount = 0,
    this.skippedCount = 0,
  });
}
