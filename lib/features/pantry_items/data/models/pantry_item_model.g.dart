// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PantryItemModelAdapter extends TypeAdapter<PantryItemModel> {
  @override
  final int typeId = 0;

  @override
  PantryItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PantryItemModel(
      id: fields[0] as String,
      name: fields[1] as String,
      quantity: fields[2] as int,
      category: fields[3] as String,
      expirationDate: fields[4] as DateTime?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PantryItemModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.expirationDate)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PantryItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
