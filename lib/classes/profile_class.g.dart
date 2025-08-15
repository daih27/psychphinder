// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final typeId = 2;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      name: fields[0] as String,
      widgetTopLeft: fields[1] as String,
      widgetTopRight: fields[2] as String,
      widgetBottomLeft: fields[3] as String,
      widgetBottomRight: fields[4] as String,
      bgColor: (fields[5] as num).toInt(),
      topLeftColor: (fields[6] as num).toInt(),
      topRightColor: (fields[7] as num).toInt(),
      bottomLeftColor: (fields[8] as num).toInt(),
      bottomRightColor: (fields[9] as num).toInt(),
      lineColor: (fields[10] as num).toInt(),
      beforeLineColor: (fields[11] as num).toInt(),
      afterLineColor: (fields[12] as num).toInt(),
      psychphinderColor: (fields[13] as num).toInt(),
      backgroundImageColor: (fields[14] as num).toInt(),
      showMadeWithPsychphinder: fields[15] as bool,
      applyGradient: fields[16] as bool,
      showBackgroundImage: fields[17] as bool,
      backgroundSize: (fields[18] as num).toDouble(),
      selectedImgs: (fields[19] as List).cast<bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.widgetTopLeft)
      ..writeByte(2)
      ..write(obj.widgetTopRight)
      ..writeByte(3)
      ..write(obj.widgetBottomLeft)
      ..writeByte(4)
      ..write(obj.widgetBottomRight)
      ..writeByte(5)
      ..write(obj.bgColor)
      ..writeByte(6)
      ..write(obj.topLeftColor)
      ..writeByte(7)
      ..write(obj.topRightColor)
      ..writeByte(8)
      ..write(obj.bottomLeftColor)
      ..writeByte(9)
      ..write(obj.bottomRightColor)
      ..writeByte(10)
      ..write(obj.lineColor)
      ..writeByte(11)
      ..write(obj.beforeLineColor)
      ..writeByte(12)
      ..write(obj.afterLineColor)
      ..writeByte(13)
      ..write(obj.psychphinderColor)
      ..writeByte(14)
      ..write(obj.backgroundImageColor)
      ..writeByte(15)
      ..write(obj.showMadeWithPsychphinder)
      ..writeByte(16)
      ..write(obj.applyGradient)
      ..writeByte(17)
      ..write(obj.showBackgroundImage)
      ..writeByte(18)
      ..write(obj.backgroundSize)
      ..writeByte(19)
      ..write(obj.selectedImgs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
