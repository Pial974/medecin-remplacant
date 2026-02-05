import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 1)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String typeNotification; // Paiement en retard, URSSAF, Déclaration fiscale

  @HiveField(2)
  final String titre;

  @HiveField(3)
  final String message;

  @HiveField(4)
  final DateTime dateNotification;

  @HiveField(5)
  final String statut; // Active, Traitée, Ignorée

  @HiveField(6)
  final String? remplacementId;

  @HiveField(7)
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    required this.typeNotification,
    required this.titre,
    required this.message,
    required this.dateNotification,
    this.statut = 'Active',
    this.remplacementId,
    this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString(),
      typeNotification: map['type_notification'] as String,
      titre: map['titre'] as String,
      message: map['message'] as String,
      dateNotification: DateTime.parse(map['date_notification'] as String),
      statut: map['statut'] as String? ?? 'Active',
      remplacementId: map['remplacement_id']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type_notification': typeNotification,
      'titre': titre,
      'message': message,
      'date_notification': dateNotification.toIso8601String().split('T')[0],
      'statut': statut,
      'remplacement_id': remplacementId,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? typeNotification,
    String? titre,
    String? message,
    DateTime? dateNotification,
    String? statut,
    String? remplacementId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      typeNotification: typeNotification ?? this.typeNotification,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      dateNotification: dateNotification ?? this.dateNotification,
      statut: statut ?? this.statut,
      remplacementId: remplacementId ?? this.remplacementId,
      createdAt: createdAt,
    );
  }
}

enum TypeNotification {
  paiementEnRetard('Paiement en retard'),
  urssaf('URSSAF'),
  declarationFiscale('Déclaration fiscale');

  final String label;
  const TypeNotification(this.label);
}

enum StatutNotification {
  active('Active'),
  traitee('Traitée'),
  ignoree('Ignorée');

  final String label;
  const StatutNotification(this.label);
}
