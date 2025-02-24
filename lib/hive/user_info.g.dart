// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserInfoAdapter extends TypeAdapter<UserInfo> {
  @override
  final int typeId = 0;

  @override
  UserInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return UserInfo(
      id: fields[0] is int
          ? fields[0] as int
          : int.tryParse(fields[0].toString()) ?? 0,
      accountNo: fields[1] as String,
      reward: fields[2] is int
          ? fields[2] as int
          : int.tryParse(fields[2].toString()) ?? 0,
      blovk: fields[3] as String,
      dateTime: fields[4] is String
          ? fields[4] as String
          : (fields[4] as DateTime).toIso8601String(), // ✅ Fix applied
      isSynced: fields[5] is int
          ? fields[5] as int
          : int.tryParse(fields[5].toString()) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, UserInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.accountNo)
      ..writeByte(2)
      ..write(obj.reward)
      ..writeByte(3)
      ..write(obj.blovk)
      ..writeByte(4)
      ..write(obj.dateTime)
      ..writeByte(5)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
