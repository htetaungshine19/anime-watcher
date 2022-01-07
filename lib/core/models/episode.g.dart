// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 1;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Episode(
      id: fields[0] as String,
      servers: (fields[1] as List).cast<Servers>(),
      type: fields[2] as EpisodeType,
      downloadId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.servers)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.downloadId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServersAdapter extends TypeAdapter<Servers> {
  @override
  final int typeId = 2;

  @override
  Servers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Servers(
      name: fields[0] as String,
      iframe: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Servers obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.iframe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EpisodeTypeAdapter extends TypeAdapter<EpisodeType> {
  @override
  final int typeId = 90;

  @override
  EpisodeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EpisodeType.network;
      case 1:
        return EpisodeType.iframe;
      case 2:
        return EpisodeType.file;
      default:
        return EpisodeType.network;
    }
  }

  @override
  void write(BinaryWriter writer, EpisodeType obj) {
    switch (obj) {
      case EpisodeType.network:
        writer.writeByte(0);
        break;
      case EpisodeType.iframe:
        writer.writeByte(1);
        break;
      case EpisodeType.file:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
