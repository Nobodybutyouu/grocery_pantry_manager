// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertSettingsModelAdapter extends TypeAdapter<AlertSettingsModel> {
  @override
  final int typeId = 1;

  @override
  AlertSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertSettingsModel(
      id: fields[0] as String,
      lowStockThreshold: fields[1] as int,
      expirationWarningDays: fields[2] as int,
      enableLowStockAlerts: fields[3] as bool,
      enableExpirationAlerts: fields[4] as bool,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AlertSettingsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lowStockThreshold)
      ..writeByte(2)
      ..write(obj.expirationWarningDays)
      ..writeByte(3)
      ..write(obj.enableLowStockAlerts)
      ..writeByte(4)
      ..write(obj.enableExpirationAlerts)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
