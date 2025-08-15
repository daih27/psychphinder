// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhraseAdapter extends TypeAdapter<Phrase> {
  @override
  final typeId = 1;

  @override
  Phrase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Phrase(
      id: (fields[0] as num).toInt(),
      season: (fields[1] as num).toInt(),
      episode: (fields[2] as num).toInt(),
      sequenceInEpisode: (fields[7] as num).toInt(),
      name: fields[3] as String,
      time: fields[4] as String,
      line: fields[5] as String,
      reference: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Phrase obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.reference)
      ..writeByte(7)
      ..write(obj.sequenceInEpisode);
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
