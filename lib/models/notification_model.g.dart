// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 1;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      id: fields[0] as String?,
      typeNotification: fields[1] as String,
      titre: fields[2] as String,
      message: fields[3] as String,
      dateNotification: fields[4] as DateTime,
      statut: fields[5] as String? ?? 'Active',
      remplacementId: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.typeNotification)
      ..writeByte(2)
      ..write(obj.titre)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.dateNotification)
      ..writeByte(5)
      ..write(obj.statut)
      ..writeByte(6)
      ..write(obj.remplacementId)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
