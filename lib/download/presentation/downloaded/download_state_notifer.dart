import 'dart:io';
import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/download.dart';
import 'package:animely/core/models/episode.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/download/data/data_source/database/downloaded_series/repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final undefined = Object();

enum DownloadedSeriesState {
  refreshing,
  idle,
}

@immutable
class DownloadedSeriesWrapper {
  final List<DownloadedSeries> downloadedSeries;

  final DownloadedSeriesState state;
  const DownloadedSeriesWrapper({
    this.downloadedSeries = const [],
    this.state = DownloadedSeriesState.idle,
  });

  DownloadedSeriesWrapper copyWith({
    List<DownloadedSeries>? downloadedSeries,
    DownloadedSeriesState? state,
  }) {
    return DownloadedSeriesWrapper(
      downloadedSeries: downloadedSeries ?? this.downloadedSeries,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['DownloadedSeries'] = downloadedSeries.map((v) => v.toJson()).toList();
    return data;
  }
}

class DownloadedSeriesNotifier extends StateNotifier<DownloadedSeriesWrapper> {
  DownloadedSeriesNotifier() : super(const DownloadedSeriesWrapper()) {
    init();
  }

  void init() async {
    final res = await DownloadedSeriesRepo.getDownloadedSeries();
    if (res.state == NetworkState.success) {
      state = state.copyWith(downloadedSeries: res.data);
    }
  }

  Future<NetworkResult> addDownloadSeries(Anime anime, Episode episode) async {
    try {
      final newList = [...state.downloadedSeries];
      bool found = false;
      for (var i in newList) {
        if (i.anime.id == anime.id) {
          final newD =
              i.copyWith(downloadedEpisode: [...i.downloadedEpisode, episode]);
          newList.remove(i);
          await DownloadedSeriesRepo.deleteDownloadedSerie(i);
          newList.add(newD);
          await DownloadedSeriesRepo.addDownloadedSerie(newD);
          found = true;
          break;
        }
      }
      if (!found) {
        await DownloadedSeriesRepo.addDownloadedSerie(
            DownloadedSeries(anime: anime, downloadedEpisode: [episode]));
        newList
            .add(DownloadedSeries(anime: anime, downloadedEpisode: [episode]));
      }
      state = state.copyWith(downloadedSeries: newList);
      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> deleteDownloadSeries(Anime anime) async {
    try {
      final newList = [...state.downloadedSeries];
      for (var i in newList) {
        if (i.anime.id == anime.id) {
          for (var j in i.downloadedEpisode) {
            for (var k in j.servers) {
              if (k.name == 'file') {
                await deleteFile(k.iframe);
              }
            }
          }
          await DownloadedSeriesRepo.deleteDownloadedSerie(i);
          newList.remove(i);
          break;
        }
      }
      state = state.copyWith(downloadedSeries: newList);

      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> deleteAllDownloadSeries() async {
    try {
      await DownloadedSeriesRepo.clearAllDownloadedSeries();
      final dir = Directory(Constant.externalStorageDir + "/");
      await dir.delete(recursive: true);
      state = state
          .copyWith(downloadedSeries: [], state: DownloadedSeriesState.idle);
      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> updateLibraryAnimeEp(Anime anime) async {
    try {
      final newSeries = [...state.downloadedSeries];
      for (var i in newSeries) {
        if (i.anime.id == anime.id &&
            i.anime.totalEpisodes != anime.totalEpisodes) {
          await DownloadedSeriesRepo.deleteDownloadedSerie(i);
          final temp = i.copyWith(
            anime: anime,
          );
          newSeries.remove(i);
          newSeries.add(temp);
          await DownloadedSeriesRepo.addDownloadedSerie(temp);
          break;
        }
      }
      state = state.copyWith(downloadedSeries: newSeries);
      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await File(path).delete();
    } catch (_) {}
  }

  Future<NetworkResult> deleteEpisodeOfDownloadedSeries(
      Anime anime, String episodeId) async {
    try {
      final newList = [...state.downloadedSeries];
      for (var element in state.downloadedSeries) {
        if (element.anime.id == anime.id) {
          newList.remove(element);
          await DownloadedSeriesRepo.deleteDownloadedSerie(element);
          final newEpL = [...element.downloadedEpisode];
          for (var i in element.downloadedEpisode) {
            if (i.id == episodeId) {
              newEpL.remove(i);
              for (var j in i.servers) {
                if (j.name == 'file') {
                  await deleteFile(j.iframe);
                  break;
                }
              }
              break;
            }
          }
          if (newEpL.isNotEmpty) {
            await DownloadedSeriesRepo.addDownloadedSerie(
                element.copyWith(downloadedEpisode: newEpL));
            newList.add(element.copyWith(downloadedEpisode: newEpL));
          }

          state = state.copyWith(downloadedSeries: newList);
          break;
        }
      }

      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }
}
