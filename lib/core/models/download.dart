// import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/episode.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
part 'download.g.dart';

@immutable
@HiveType(typeId: 3)
class DownloadedSeries {
  @HiveField(0)
  final Anime anime;
  @HiveField(1)
  final List<Episode> downloadedEpisode;

  const DownloadedSeries({
    required this.anime,
    required this.downloadedEpisode,
  });

  DownloadedSeries copyWith({
    Anime? anime,
    List<Episode>? downloadedEpisode,
  }) {
    return DownloadedSeries(
      anime: anime ?? this.anime,
      downloadedEpisode: downloadedEpisode ?? this.downloadedEpisode,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['anime'] = anime;
    data['episodes'] = downloadedEpisode.map((v) => v.toJson()).toList();
    return data;
  }
}

@immutable
@HiveType(typeId: 5)
class DownloadQue {
  @HiveField(0)
  final Episode episode;
  @HiveField(1)
  final String id;
  @HiveField(2)
  final Anime anime;
  @HiveField(3)
  final int progress;
  @HiveField(4)
  final String fileSize;
  @HiveField(5)
  final String resolution;

  const DownloadQue({
    required this.episode,
    required this.id,
    required this.anime,
    required this.progress,
    required this.fileSize,
    this.resolution = "480",
  });

  DownloadQue copyWith({
    Anime? anime,
    String? id,
    String? fileSize,
    String? resolution,
    Episode? episode,
    int? progress,
  }) {
    return DownloadQue(
      anime: anime ?? this.anime,
      id: id ?? this.id,
      episode: episode ?? this.episode,
      progress: progress ?? this.progress,
      fileSize: fileSize ?? this.fileSize,
      resolution: resolution ?? this.resolution,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['anime'] = anime;
    data['id'] = id;
    data['fileSize'] = fileSize;
    data['episode'] = episode;
    data['progress'] = progress;
    data['resolution'] = resolution;
    return data;
  }
}
