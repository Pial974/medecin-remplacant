import 'package:hive_flutter/hive_flutter.dart';
import '../models/remplacement.dart';
import '../models/document.dart';
import '../models/notification_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  static const String _remplacementsBoxName = 'remplacements';
  static const String _documentsBoxName = 'documents';
  static const String _notificationsBoxName = 'notifications';

  Box<Remplacement>? _remplacementsBox;
  Box<Document>? _documentsBox;
  Box<NotificationModel>? _notificationsBox;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  // Initialise Hive et ouvre les boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Enregistrer les adaptateurs
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RemplacementAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DocumentAdapter());
    }
  }

  Future<Box<Remplacement>> get remplacementsBox async {
    _remplacementsBox ??= await Hive.openBox<Remplacement>(_remplacementsBoxName);
    return _remplacementsBox!;
  }

  Future<Box<Document>> get documentsBox async {
    _documentsBox ??= await Hive.openBox<Document>(_documentsBoxName);
    return _documentsBox!;
  }

  Future<Box<NotificationModel>> get notificationsBox async {
    _notificationsBox ??= await Hive.openBox<NotificationModel>(_notificationsBoxName);
    return _notificationsBox!;
  }

  // Génère un ID unique
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
           '_${(DateTime.now().microsecond * 1000 + DateTime.now().hashCode).abs() % 100000}';
  }

  // ==================== REMPLACEMENTS ====================

  Future<String> insertRemplacement(Remplacement remplacement) async {
    final box = await remplacementsBox;
    final id = _generateId();
    final newRemplacement = remplacement.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );
    await box.put(id, newRemplacement);
    return id;
  }

  Future<List<Remplacement>> getAllRemplacements() async {
    final box = await remplacementsBox;
    final remplacements = box.values.toList();
    remplacements.sort((a, b) => b.dateDebut.compareTo(a.dateDebut));
    return remplacements;
  }

  Future<List<Remplacement>> getRemplacementsByYear(int year) async {
    final box = await remplacementsBox;
    final remplacements = box.values
        .where((r) => r.dateDebut.year == year)
        .toList();
    remplacements.sort((a, b) => b.dateDebut.compareTo(a.dateDebut));
    return remplacements;
  }

  Future<List<Remplacement>> getRemplacementsByMedecin(String medecin) async {
    final box = await remplacementsBox;
    final remplacements = box.values
        .where((r) => r.medecinRemplace == medecin)
        .toList();
    remplacements.sort((a, b) => b.dateDebut.compareTo(a.dateDebut));
    return remplacements;
  }

  Future<List<Remplacement>> getRemplacementsEnAttente() async {
    final box = await remplacementsBox;
    final remplacements = box.values
        .where((r) => r.statutPaiement != 'Payé')
        .toList();
    remplacements.sort((a, b) => a.dateFin.compareTo(b.dateFin));
    return remplacements;
  }

  Future<void> updateRemplacement(Remplacement remplacement) async {
    final box = await remplacementsBox;
    if (remplacement.id != null) {
      final updatedRemplacement = remplacement.copyWith(
        updatedAt: DateTime.now(),
      );
      await box.put(remplacement.id, updatedRemplacement);
    }
  }

  Future<void> deleteRemplacement(String id) async {
    final box = await remplacementsBox;
    await box.delete(id);

    // Supprimer aussi les documents associés
    final docsBox = await documentsBox;
    final docsToDelete = docsBox.values
        .where((d) => d.remplacementId == id)
        .map((d) => d.id)
        .whereType<String>()
        .toList();
    for (final docId in docsToDelete) {
      await docsBox.delete(docId);
    }
  }

  Future<List<String>> getDistinctMedecins() async {
    final box = await remplacementsBox;
    final medecins = box.values
        .map((r) => r.medecinRemplace)
        .toSet()
        .toList();
    medecins.sort();
    return medecins;
  }

  // ==================== DOCUMENTS ====================

  Future<String> insertDocument(Document document) async {
    final box = await documentsBox;
    final id = _generateId();
    final newDocument = Document(
      id: id,
      remplacementId: document.remplacementId,
      typeDocument: document.typeDocument,
      nomFichier: document.nomFichier,
      cheminFichier: document.cheminFichier,
      tailleFichier: document.tailleFichier,
      dateUpload: DateTime.now(),
    );
    await box.put(id, newDocument);
    return id;
  }

  Future<List<Document>> getDocumentsByRemplacement(String remplacementId) async {
    final box = await documentsBox;
    return box.values
        .where((d) => d.remplacementId == remplacementId)
        .toList();
  }

  Future<void> deleteDocument(String id) async {
    final box = await documentsBox;
    await box.delete(id);
  }

  // ==================== NOTIFICATIONS ====================

  Future<String> insertNotification(NotificationModel notification) async {
    final box = await notificationsBox;
    final id = _generateId();
    final newNotification = NotificationModel(
      id: id,
      typeNotification: notification.typeNotification,
      titre: notification.titre,
      message: notification.message,
      dateNotification: notification.dateNotification,
      statut: notification.statut,
      remplacementId: notification.remplacementId,
      createdAt: DateTime.now(),
    );
    await box.put(id, newNotification);
    return id;
  }

  Future<List<NotificationModel>> getActiveNotifications() async {
    final box = await notificationsBox;
    final notifications = box.values
        .where((n) => n.statut == 'Active')
        .toList();
    notifications.sort((a, b) => b.dateNotification.compareTo(a.dateNotification));
    return notifications;
  }

  Future<void> updateNotificationStatut(String id, String statut) async {
    final box = await notificationsBox;
    final notification = box.get(id);
    if (notification != null) {
      final updated = notification.copyWith(statut: statut);
      await box.put(id, updated);
    }
  }

  // ==================== STATISTIQUES ====================

  Future<Map<String, dynamic>> getStatistiquesAnnuelles(int year) async {
    final remplacements = await getRemplacementsByYear(year);

    double totalBrut = 0;
    double totalNet = 0;
    double totalJours = 0;

    for (final r in remplacements) {
      totalBrut += r.montantAvantRetrocession;
      totalNet += r.montantNet;
      totalJours += r.nombreJours;
    }

    return {
      'totalBrut': totalBrut,
      'totalNet': totalNet,
      'totalJours': totalJours,
      'nbRemplacements': remplacements.length,
    };
  }

  Future<List<Map<String, dynamic>>> getRevenusParMois(int year) async {
    final remplacements = await getRemplacementsByYear(year);

    // Grouper par mois
    final Map<int, List<Remplacement>> parMois = {};
    for (final r in remplacements) {
      final mois = r.dateDebut.month;
      parMois.putIfAbsent(mois, () => []);
      parMois[mois]!.add(r);
    }

    final result = <Map<String, dynamic>>[];
    for (int m = 1; m <= 12; m++) {
      if (parMois.containsKey(m)) {
        final remps = parMois[m]!;
        double montantApresRetro = 0;
        double net = 0;

        for (final r in remps) {
          montantApresRetro += r.montantApresRetrocession;
          net += r.montantNet;
        }

        result.add({
          'mois': m.toString().padLeft(2, '0'),
          'montant_apres_retro': montantApresRetro,
          'net': net,
        });
      }
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getStatParMedecin() async {
    final box = await remplacementsBox;
    final allRemplacements = box.values.toList();

    // Grouper par médecin
    final Map<String, List<Remplacement>> parMedecin = {};
    for (final r in allRemplacements) {
      parMedecin.putIfAbsent(r.medecinRemplace, () => []);
      parMedecin[r.medecinRemplace]!.add(r);
    }

    final result = <Map<String, dynamic>>[];
    for (final entry in parMedecin.entries) {
      final remps = entry.value;
      double totalJours = 0;
      double totalTaux = 0;
      double totalNet = 0;

      for (final r in remps) {
        totalJours += r.nombreJours;
        totalTaux += r.tauxRetrocession;
        totalNet += r.montantNet;
      }

      result.add({
        'medecin_remplace': entry.key,
        'nb_remplacements': remps.length,
        'total_jours': totalJours,
        'taux_moyen': totalTaux / remps.length,
        'total_net': totalNet,
        'revenu_jour_moyen': totalJours > 0 ? totalNet / totalJours : 0,
      });
    }

    result.sort((a, b) => (b['total_net'] as double).compareTo(a['total_net'] as double));
    return result;
  }

  // ==================== RESET ====================

  Future<void> resetDatabase() async {
    // Fermer et supprimer toutes les boxes
    if (_remplacementsBox != null && _remplacementsBox!.isOpen) {
      await _remplacementsBox!.clear();
      await _remplacementsBox!.close();
      _remplacementsBox = null;
    }

    if (_documentsBox != null && _documentsBox!.isOpen) {
      await _documentsBox!.clear();
      await _documentsBox!.close();
      _documentsBox = null;
    }

    if (_notificationsBox != null && _notificationsBox!.isOpen) {
      await _notificationsBox!.clear();
      await _notificationsBox!.close();
      _notificationsBox = null;
    }

    await Hive.deleteBoxFromDisk(_remplacementsBoxName);
    await Hive.deleteBoxFromDisk(_documentsBoxName);
    await Hive.deleteBoxFromDisk(_notificationsBoxName);
  }

  // ==================== EXPORT/IMPORT ====================

  Future<Map<String, dynamic>> exportAllData() async {
    final remplacementsBox = await this.remplacementsBox;
    final documentsBox = await this.documentsBox;
    final notificationsBox = await this.notificationsBox;

    return {
      'remplacements': remplacementsBox.values.map((r) => r.toMap()).toList(),
      'documents': documentsBox.values.map((d) => d.toMap()).toList(),
      'notifications': notificationsBox.values.map((n) => n.toMap()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '2.0', // Version Hive
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    // Vider les boxes existantes
    final remplacementsBox = await this.remplacementsBox;
    final documentsBox = await this.documentsBox;
    final notificationsBox = await this.notificationsBox;

    await remplacementsBox.clear();
    await documentsBox.clear();
    await notificationsBox.clear();

    // Importer les remplacements
    final remplacementsList = data['remplacements'] as List<dynamic>? ?? [];
    for (final r in remplacementsList) {
      final remplacement = Remplacement.fromMap(r as Map<String, dynamic>);
      final id = remplacement.id ?? _generateId();
      await remplacementsBox.put(id, remplacement.copyWith(id: id));
    }

    // Importer les documents
    final documentsList = data['documents'] as List<dynamic>? ?? [];
    for (final d in documentsList) {
      final document = Document.fromMap(d as Map<String, dynamic>);
      final id = document.id ?? _generateId();
      await documentsBox.put(id, Document(
        id: id,
        remplacementId: document.remplacementId,
        typeDocument: document.typeDocument,
        nomFichier: document.nomFichier,
        cheminFichier: document.cheminFichier,
        tailleFichier: document.tailleFichier,
        dateUpload: document.dateUpload,
      ));
    }

    // Importer les notifications
    final notificationsList = data['notifications'] as List<dynamic>? ?? [];
    for (final n in notificationsList) {
      final notification = NotificationModel.fromMap(n as Map<String, dynamic>);
      final id = notification.id ?? _generateId();
      await notificationsBox.put(id, NotificationModel(
        id: id,
        typeNotification: notification.typeNotification,
        titre: notification.titre,
        message: notification.message,
        dateNotification: notification.dateNotification,
        statut: notification.statut,
        remplacementId: notification.remplacementId,
        createdAt: notification.createdAt,
      ));
    }
  }
}
