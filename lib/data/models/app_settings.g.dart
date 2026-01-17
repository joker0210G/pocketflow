// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as String,
      isFixedIncome: fields[1] as bool,
      monthlyBills: fields[2] as double,
      nextPayDate: fields[3] as DateTime?,
      customTermDays: fields[4] as int?,
      termStartDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.isFixedIncome)
      ..writeByte(2)
      ..write(obj.monthlyBills)
      ..writeByte(3)
      ..write(obj.nextPayDate)
      ..writeByte(4)
      ..write(obj.customTermDays)
      ..writeByte(5)
      ..write(obj.termStartDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
