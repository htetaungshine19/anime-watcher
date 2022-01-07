// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadedSeriesAdapter extends TypeAdapter<DownloadedSeries> {
  @override
  final int typeId = 3;

  @override
  DownloadedSeries read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadedSeries(
      anime: fields[0] as Anime,
      downloadedEpisode: (fields[1] as List).cast<Episode>(),
    );
  }

  @override
  void write(BinaryWriter writer, DownloadedSeries obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.anime)
      ..writeByte(1)
      ..write(obj.downloadedEpisode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedSeriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DownloadQueAdapter extends TypeAdapter<DownloadQue> {
  @override
  final int typeId = 5;

  @override
  DownloadQue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadQue(
      episode: fields[0] as Episode,
      id: fields[1] as String,
      anime: fields[2] as Anime,
      progress: fields[3] as int,
      fileSize: fields[4] as String,
      resolution: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadQue obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.episode)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.anime)
      ..writeByte(3)
      ..write(obj.progress)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.resolution);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadQueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
