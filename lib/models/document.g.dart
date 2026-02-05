// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentAdapter extends TypeAdapter<Document> {
  @override
  final int typeId = 2;

  @override
  Document read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Document(
      id: fields[0] as String?,
      remplacementId: fields[1] as String,
      typeDocument: fields[2] as String,
      nomFichier: fields[3] as String,
      cheminFichier: fields[4] as String,
      tailleFichier: fields[5] as int?,
      dateUpload: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Document obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.remplacementId)
      ..writeByte(2)
      ..write(obj.typeDocument)
      ..writeByte(3)
      ..write(obj.nomFichier)
      ..writeByte(4)
      ..write(obj.cheminFichier)
      ..writeByte(5)
      ..write(obj.tailleFichier)
      ..writeByte(6)
      ..write(obj.dateUpload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
