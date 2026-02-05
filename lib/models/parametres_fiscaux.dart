class ParametresFiscaux {
  final int? id;
  final int annee;
  final double tauxUrssaf;
  final Map<String, dynamic>? tauxIrTranches;
  final double? plafondSecu;
  final double abattementMicroBnc;
  final DateTime? createdAt;

  ParametresFiscaux({
    this.id,
    required this.annee,
    this.tauxUrssaf = 13.5,
    this.tauxIrTranches,
    this.plafondSecu,
    this.abattementMicroBnc = 34.0,
    this.createdAt,
  });

  factory ParametresFiscaux.fromMap(Map<String, dynamic> map) {
    return ParametresFiscaux(
      id: map['id'] as int?,
      annee: map['annee'] as int,
      tauxUrssaf: (map['taux_urssaf'] as num?)?.toDouble() ?? 13.5,
      tauxIrTranches: map['taux_ir_tranches'] as Map<String, dynamic>?,
      plafondSecu: (map['plafond_secu'] as num?)?.toDouble(),
      abattementMicroBnc:
          (map['abattement_micro_bnc'] as num?)?.toDouble() ?? 34.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'annee': annee,
      'taux_urssaf': tauxUrssaf,
      'taux_ir_tranches': tauxIrTranches,
      'plafond_secu': plafondSecu,
      'abattement_micro_bnc': abattementMicroBnc,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Paramètres par défaut pour 2024/2025
  static ParametresFiscaux get defaultParams => ParametresFiscaux(
        annee: DateTime.now().year,
        tauxUrssaf: 13.5,
        abattementMicroBnc: 34.0,
        tauxIrTranches: {
          'tranche1': {'min': 0, 'max': 11294, 'taux': 0},
          'tranche2': {'min': 11295, 'max': 28797, 'taux': 11},
          'tranche3': {'min': 28798, 'max': 82341, 'taux': 30},
          'tranche4': {'min': 82342, 'max': 177106, 'taux': 41},
          'tranche5': {'min': 177107, 'max': double.infinity, 'taux': 45},
        },
      );
}
