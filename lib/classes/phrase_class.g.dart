// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhraseAdapter extends TypeAdapter<Phrase> {
  @override
  final int typeId = 1;

  @override
  Phrase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Phrase(
      id: fields[0] as int,
      season: fields[1] as int,
      episode: fields[2] as int,
      name: fields[3] as String,
      time: fields[4] as String,
      line: fields[5] as String,
      reference: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Phrase obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.season)
      ..writeByte(2)
      ..write(obj.episode)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.line)
      ..writeByte(6)
      ..write(obj.reference);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhraseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
