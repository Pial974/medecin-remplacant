// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remplacement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RemplacementAdapter extends TypeAdapter<Remplacement> {
  @override
  final int typeId = 0;

  @override
  Remplacement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Remplacement(
      id: fields[0] as String?,
      dateDebut: fields[1] as DateTime,
      dateFin: fields[2] as DateTime,
      medecinRemplace: fields[3] as String,
      nombreJours: fields[4] as double,
      tauxRetrocession: fields[5] as int,
      montantAvantRetrocession: fields[6] as double,
      modePaiement: fields[7] as String?,
      datePaiement: fields[8] as DateTime?,
      statutPaiement: fields[9] as String? ?? 'En attente',
      notes: fields[10] as String?,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Remplacement obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateDebut)
      ..writeByte(2)
      ..write(obj.dateFin)
      ..writeByte(3)
      ..write(obj.medecinRemplace)
      ..writeByte(4)
      ..write(obj.nombreJours)
      ..writeByte(5)
      ..write(obj.tauxRetrocession)
      ..writeByte(6)
      ..write(obj.montantAvantRetrocession)
      ..writeByte(7)
      ..write(obj.modePaiement)
      ..writeByte(8)
      ..write(obj.datePaiement)
      ..writeByte(9)
      ..write(obj.statutPaiement)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemplacementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
