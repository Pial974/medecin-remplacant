import 'package:hive/hive.dart';

part 'document.g.dart';

@HiveType(typeId: 2)
class Document extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String remplacementId;

  @HiveField(2)
  final String typeDocument; // Contrat, Facture, Justificatif

  @HiveField(3)
  final String nomFichier;

  @HiveField(4)
  final String cheminFichier;

  @HiveField(5)
  final int? tailleFichier;

  @HiveField(6)
  final DateTime? dateUpload;

  Document({
    this.id,
    required this.remplacementId,
    required this.typeDocument,
    required this.nomFichier,
    required this.cheminFichier,
    this.tailleFichier,
    this.dateUpload,
  });

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id']?.toString(),
      remplacementId: map['remplacement_id'].toString(),
      typeDocument: map['type_document'] as String,
      nomFichier: map['nom_fichier'] as String,
      cheminFichier: map['chemin_fichier'] as String,
      tailleFichier: map['taille_fichier'] as int?,
      dateUpload: map['date_upload'] != null
          ? DateTime.parse(map['date_upload'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'remplacement_id': remplacementId,
      'type_document': typeDocument,
      'nom_fichier': nomFichier,
      'chemin_fichier': cheminFichier,
      'taille_fichier': tailleFichier,
      'date_upload': dateUpload?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}

enum TypeDocument {
  contrat('Contrat'),
  facture('Facture'),
  justificatif('Justificatif');

  final String label;
  const TypeDocument(this.label);
}
