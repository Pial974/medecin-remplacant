import 'package:flutter/foundation.dart';
import '../models/remplacement.dart';
import '../models/notification_model.dart';
import '../services/database_service.dart';

// Seuils URSSAF
const double seuilUrssafBas = 19000.0;
const double seuilUrssafHaut = 38000.0;
const double tauxUrssafBas = 13.5;
const double tauxUrssafMoyen = 21.2;

enum StatutFiscal {
  microBNC,        // < 19 000€ - taux 13.5%
  microBNCMajore,  // 19 000€ - 38 000€ - taux 21.2%
  depassement,     // > 38 000€ - changement de régime
}

class RemplacementProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Remplacement> _remplacements = [];
  List<NotificationModel> _notifications = [];
  Map<String, dynamic> _statistiques = {};
  List<Map<String, dynamic>> _revenusParMois = [];
  List<Map<String, dynamic>> _statsParMedecin = [];
  List<String> _medecins = [];
  bool _isLoading = false;
  String? _error;
  int _selectedYear = DateTime.now().year;

  // Recherche et filtres
  String _searchQuery = '';
  String? _filterStatut; // 'Payé', 'En attente', 'En retard', ou null pour tous
  String? _filterMedecin;

  // Getters
  String get searchQuery => _searchQuery;
  String? get filterStatut => _filterStatut;
  String? get filterMedecin => _filterMedecin;
  bool get hasActiveFilters => _searchQuery.isNotEmpty || _filterStatut != null || _filterMedecin != null;

  // Liste filtrée des remplacements
  List<Remplacement> get remplacements {
    List<Remplacement> result = _remplacements;

    // Filtre par recherche textuelle
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((r) {
        return r.medecinRemplace.toLowerCase().contains(query) ||
            (r.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtre par statut
    if (_filterStatut != null) {
      result = result.where((r) => r.statutPaiement == _filterStatut).toList();
    }

    // Filtre par médecin
    if (_filterMedecin != null) {
      result = result.where((r) => r.medecinRemplace == _filterMedecin).toList();
    }

    return result;
  }

  // Tous les remplacements sans filtres (pour les calculs)
  List<Remplacement> get allRemplacements => _remplacements;
  List<NotificationModel> get notifications => _notifications;
  Map<String, dynamic> get statistiques => _statistiques;
  List<Map<String, dynamic>> get revenusParMois => _revenusParMois;
  List<Map<String, dynamic>> get statsParMedecin => _statsParMedecin;
  List<String> get medecins => _medecins;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedYear => _selectedYear;

  // ==================== GESTION URSSAF ====================

  // Statut fiscal actuel basé sur le brut annuel
  StatutFiscal get statutFiscal {
    if (totalBrut >= seuilUrssafHaut) {
      return StatutFiscal.depassement;
    } else if (totalBrut >= seuilUrssafBas) {
      return StatutFiscal.microBNCMajore;
    }
    return StatutFiscal.microBNC;
  }

  // Taux URSSAF actuel
  double get tauxUrssafActuel {
    switch (statutFiscal) {
      case StatutFiscal.microBNC:
        return tauxUrssafBas;
      case StatutFiscal.microBNCMajore:
      case StatutFiscal.depassement:
        return tauxUrssafMoyen;
    }
  }

  // Libellé du statut fiscal
  String get statutFiscalLabel {
    switch (statutFiscal) {
      case StatutFiscal.microBNC:
        return 'Micro-BNC (13,5%)';
      case StatutFiscal.microBNCMajore:
        return 'Micro-BNC majoré (21,2%)';
      case StatutFiscal.depassement:
        return 'Dépassement seuil micro-BNC';
    }
  }

  // Montant restant avant prochain seuil
  double get montantAvantProchainSeuil {
    if (totalBrut < seuilUrssafBas) {
      return seuilUrssafBas - totalBrut;
    } else if (totalBrut < seuilUrssafHaut) {
      return seuilUrssafHaut - totalBrut;
    }
    return 0;
  }

  // Prochain seuil
  double? get prochainSeuil {
    if (totalBrut < seuilUrssafBas) return seuilUrssafBas;
    if (totalBrut < seuilUrssafHaut) return seuilUrssafHaut;
    return null;
  }

  // Message d'alerte selon le statut
  String? get alerteStatutFiscal {
    switch (statutFiscal) {
      case StatutFiscal.microBNC:
        if (totalBrut > seuilUrssafBas * 0.8) {
          return 'Attention : Vous approchez du seuil de ${seuilUrssafBas.toInt()}€. '
              'Au-delà, votre taux URSSAF passera de 13,5% à 21,2%.';
        }
        return null;
      case StatutFiscal.microBNCMajore:
        return 'Votre chiffre d\'affaires dépasse ${seuilUrssafBas.toInt()}€. '
            'Le taux URSSAF est maintenant de 21,2% au lieu de 13,5%.';
      case StatutFiscal.depassement:
        return 'ATTENTION : Vous dépassez le seuil de ${seuilUrssafHaut.toInt()}€ ! '
            'Vous devez changer de régime fiscal. '
            'Contactez votre comptable pour effectuer les démarches nécessaires.';
    }
  }

  // Calculs globaux
  double get totalBrut => _remplacements.fold(
      0, (sum, r) => sum + r.montantAvantRetrocession);

  double get totalApresRetro =>
      _remplacements.fold(0, (sum, r) => sum + r.montantApresRetrocession);

  // URSSAF recalculé avec le taux actuel
  double get totalUrssaf => totalApresRetro * (tauxUrssafActuel / 100);

  // Net recalculé avec le bon taux URSSAF
  double get totalNet => totalApresRetro - totalUrssaf;

  double get totalJours =>
      _remplacements.fold(0, (sum, r) => sum + r.nombreJours);

  double get revenuMoyenParJour =>
      totalJours > 0 ? totalNet / totalJours : 0;

  double get tauxRetroMoyenPondere {
    if (totalBrut == 0) return 0;
    final weighted = _remplacements.fold(
        0.0,
        (sum, r) =>
            sum + (r.tauxRetrocession * r.montantAvantRetrocession));
    return weighted / totalBrut;
  }

  int get nbEnAttente =>
      _remplacements.where((r) => r.statutPaiement == 'En attente').length;

  int get nbEnRetard =>
      _remplacements.where((r) => r.statutPaiement == 'En retard').length;

  double get montantEnAttente => _remplacements
      .where((r) => r.statutPaiement != 'Payé')
      .fold(0, (sum, r) => sum + r.netAvantImpots);

  // Initialisation
  Future<void> init() async {
    await loadRemplacements();
    await loadNotifications();
    await loadStatistiques();
    await loadMedecins();
  }

  // Chargement des remplacements
  Future<void> loadRemplacements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Sauvegarder le statut précédent
      final oldStatut = _remplacements.isNotEmpty ? statutFiscal : null;

      _remplacements = await _db.getRemplacementsByYear(_selectedYear);
      await _checkPaiementsEnRetard();

      // Vérifier si le statut fiscal a changé
      if (oldStatut != null && oldStatut != statutFiscal) {
        await _createNotificationChangementStatut(oldStatut, statutFiscal);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer une notification lors d'un changement de statut fiscal
  Future<void> _createNotificationChangementStatut(
      StatutFiscal ancien, StatutFiscal nouveau) async {
    String titre;
    String message;
    String type;

    if (nouveau == StatutFiscal.microBNCMajore) {
      titre = 'Changement de taux URSSAF';
      message = 'Votre chiffre d\'affaires a dépassé ${seuilUrssafBas.toInt()}€. '
          'Votre taux URSSAF passe de 13,5% à 21,2%.';
      type = 'Changement taux URSSAF';
    } else if (nouveau == StatutFiscal.depassement) {
      titre = 'DÉPASSEMENT DU SEUIL MICRO-BNC';
      message = 'Votre chiffre d\'affaires a dépassé ${seuilUrssafHaut.toInt()}€ ! '
          'Vous devez impérativement changer de régime fiscal. '
          'Contactez votre comptable pour effectuer les démarches nécessaires.';
      type = 'Dépassement seuil';
    } else {
      return; // Pas de notification pour retour à un taux inférieur
    }

    final notification = NotificationModel(
      typeNotification: type,
      titre: titre,
      message: message,
      dateNotification: DateTime.now(),
    );
    await _db.insertNotification(notification);
    await loadNotifications();
  }

  // Changer l'année sélectionnée
  Future<void> setYear(int year) async {
    _selectedYear = year;
    await loadRemplacements();
    await loadStatistiques();
  }

  // Ajouter un remplacement
  Future<void> addRemplacement(Remplacement remplacement) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.insertRemplacement(remplacement);
      await loadRemplacements();
      await loadStatistiques();
      await loadMedecins();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour un remplacement
  Future<void> updateRemplacement(Remplacement remplacement) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.updateRemplacement(remplacement);
      await loadRemplacements();
      await loadStatistiques();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Supprimer un remplacement
  Future<void> deleteRemplacement(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.deleteRemplacement(id);
      await loadRemplacements();
      await loadStatistiques();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Marquer comme payé
  Future<void> marquerCommePaye(Remplacement remplacement, {DateTime? datePaiement, String? modePaiement}) async {
    final updated = remplacement.copyWith(
      statutPaiement: 'Payé',
      datePaiement: datePaiement ?? DateTime.now(),
      modePaiement: modePaiement ?? remplacement.modePaiement,
    );
    await updateRemplacement(updated);
  }

  // Charger les notifications
  Future<void> loadNotifications() async {
    try {
      _notifications = await _db.getActiveNotifications();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Charger les statistiques
  Future<void> loadStatistiques() async {
    try {
      _statistiques = await _db.getStatistiquesAnnuelles(_selectedYear);
      _revenusParMois = await _db.getRevenusParMois(_selectedYear);
      _statsParMedecin = await _db.getStatParMedecin();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Charger la liste des médecins
  Future<void> loadMedecins() async {
    try {
      _medecins = await _db.getDistinctMedecins();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Vérifier les paiements en retard (après 30 jours)
  Future<void> _checkPaiementsEnRetard() async {
    final now = DateTime.now();
    for (final r in _remplacements) {
      if (r.statutPaiement == 'En attente') {
        final joursDepuisFin = now.difference(r.dateFin).inDays;
        if (joursDepuisFin > 30) {
          final updated = r.copyWith(statutPaiement: 'En retard');
          await _db.updateRemplacement(updated);

          // Créer notification si pas déjà existante
          final notification = NotificationModel(
            typeNotification: 'Paiement en retard',
            titre: 'Paiement en retard',
            message:
                'Le paiement pour le remplacement du Dr ${r.medecinRemplace} (${r.dateDebut.day}/${r.dateDebut.month}) est en retard de ${joursDepuisFin - 30} jours.',
            dateNotification: now,
            remplacementId: r.id,
          );
          await _db.insertNotification(notification);
        }
      }
    }
  }

  // Traiter une notification
  Future<void> traiterNotification(String id) async {
    await _db.updateNotificationStatut(id, 'Traitée');
    await loadNotifications();
  }

  // Ignorer une notification
  Future<void> ignorerNotification(String id) async {
    await _db.updateNotificationStatut(id, 'Ignorée');
    await loadNotifications();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== RECHERCHE ET FILTRES ====================

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatut(String? statut) {
    _filterStatut = statut;
    notifyListeners();
  }

  void setFilterMedecin(String? medecin) {
    _filterMedecin = medecin;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatut = null;
    _filterMedecin = null;
    notifyListeners();
  }
}
