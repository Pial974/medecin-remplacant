import 'package:hive/hive.dart';

part 'remplacement.g.dart';

@HiveType(typeId: 0)
class Remplacement extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final DateTime dateDebut;

  @HiveField(2)
  final DateTime dateFin;

  @HiveField(3)
  final String medecinRemplace;

  @HiveField(4)
  final double nombreJours;

  @HiveField(5)
  final int tauxRetrocession; // 70-80%

  @HiveField(6)
  final double montantAvantRetrocession;

  @HiveField(7)
  final String? modePaiement; // Virement, Chèque, Espèces

  @HiveField(8)
  final DateTime? datePaiement;

  @HiveField(9)
  final String statutPaiement; // En attente, Payé, En retard

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final DateTime? createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  Remplacement({
    this.id,
    required this.dateDebut,
    required this.dateFin,
    required this.medecinRemplace,
    required this.nombreJours,
    required this.tauxRetrocession,
    required this.montantAvantRetrocession,
    this.modePaiement,
    this.datePaiement,
    this.statutPaiement = 'En attente',
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Calculs automatiques
  double get montantApresRetrocession =>
      montantAvantRetrocession * (tauxRetrocession / 100);

  double get urssaf => montantApresRetrocession * 0.135;

  double get netAvantImpots => montantApresRetrocession - urssaf;

  // Alias pour compatibilité
  double get montantNet => netAvantImpots;

  double get revenueParJour =>
      nombreJours > 0 ? netAvantImpots / nombreJours : 0;

  factory Remplacement.fromMap(Map<String, dynamic> map) {
    return Remplacement(
      id: map['id']?.toString(),
      dateDebut: DateTime.parse(map['date_debut'] as String),
      dateFin: DateTime.parse(map['date_fin'] as String),
      medecinRemplace: map['medecin_remplace'] as String,
      nombreJours: (map['nombre_jours'] as num).toDouble(),
      tauxRetrocession: map['taux_retrocession'] as int,
      montantAvantRetrocession:
          (map['montant_avant_retrocession'] as num).toDouble(),
      modePaiement: map['mode_paiement'] as String?,
      datePaiement: map['date_paiement'] != null
          ? DateTime.parse(map['date_paiement'] as String)
          : null,
      statutPaiement: map['statut_paiement'] as String? ?? 'En attente',
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date_debut': dateDebut.toIso8601String().split('T')[0],
      'date_fin': dateFin.toIso8601String().split('T')[0],
      'medecin_remplace': medecinRemplace,
      'nombre_jours': nombreJours,
      'taux_retrocession': tauxRetrocession,
      'montant_avant_retrocession': montantAvantRetrocession,
      'mode_paiement': modePaiement,
      'date_paiement': datePaiement?.toIso8601String().split('T')[0],
      'statut_paiement': statutPaiement,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Remplacement copyWith({
    String? id,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? medecinRemplace,
    double? nombreJours,
    int? tauxRetrocession,
    double? montantAvantRetrocession,
    String? modePaiement,
    DateTime? datePaiement,
    String? statutPaiement,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Remplacement(
      id: id ?? this.id,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      medecinRemplace: medecinRemplace ?? this.medecinRemplace,
      nombreJours: nombreJours ?? this.nombreJours,
      tauxRetrocession: tauxRetrocession ?? this.tauxRetrocession,
      montantAvantRetrocession:
          montantAvantRetrocession ?? this.montantAvantRetrocession,
      modePaiement: modePaiement ?? this.modePaiement,
      datePaiement: datePaiement ?? this.datePaiement,
      statutPaiement: statutPaiement ?? this.statutPaiement,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// Enum pour les statuts de paiement
enum StatutPaiement {
  enAttente('En attente'),
  paye('Payé'),
  enRetard('En retard');

  final String label;
  const StatutPaiement(this.label);
}

// Enum pour les modes de paiement
enum ModePaiement {
  virement('Virement'),
  cheque('Chèque'),
  especes('Espèces');

  final String label;
  const ModePaiement(this.label);
}
