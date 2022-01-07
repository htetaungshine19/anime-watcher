// import 'package:animely/core/api/common/api.dart';
import 'package:animely/core/constants/constants.dart';
import 'package:animely/download/data/data_source/database/download_que/repo.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/download.dart';
import 'package:animely/core/models/episode.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/core/models/que_state.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/download/data/data_source/network/network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<NetworkResult> calculateFileSize(String link) async {
  try {
    String size = '0kb';
    http.Response r =
        await http.head(Uri.parse(link), headers: Constant.headers);
    final fileSize = int.parse(r.headers["content-length"]!);
    if (fileSize >= 1024 && fileSize < 1048576) {
      size = '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else if (fileSize >= 1048576 && fileSize < 1073741824) {
      size = '${(fileSize / 1048576).toStringAsFixed(2)} MB';
    } else {
      size = '${(fileSize / 1073741824).toStringAsFixed(2)} G';
    }
    return NetworkResult(state: NetworkState.success, data: size);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: '$e');
  }
}

Future<DownloadQue> download({
  required String link,
  required Anime anime,
  required Episode episode,
  String? resolution,
}) async {
  final id = DateTime.now().millisecondsSinceEpoch;
  // final fileSize = await calculateFileSize(link);
  print(link);
  final taskId = await FlutterDownloader.enqueue(
    url: link,
    savedDir: Constant.externalStorageDir,
    fileName: "$id.mp4",
    showNotification: true,
    headers: Constant.headers,
  );
  return DownloadQue(
    resolution: resolution ?? Constant.resolution,
    episode: episode.copyWith(servers: [
      ...episode.servers,
      Servers(name: "file", iframe: "${Constant.externalStorageDir}/$id.mp4")
    ], type: EpisodeType.file, downloadId: taskId),
    id: taskId ?? "",
    anime: anime,
    progress: 0,
    fileSize: "",
  );
}

final undefined = Object();

@immutable
class DownloadQueWrapper {
  final List<DownloadQue> downloadQues;
  final DownloadQue? currentQue;
  final DownloadQueState state;
  const DownloadQueWrapper({
    this.downloadQues = const [],
    this.state = DownloadQueState.idle,
    this.currentQue,
  });

  DownloadQueWrapper copyWith({
    List<DownloadQue>? downloadQues,
    DownloadQueState? state,
    Object? currentQue,
  }) {
    return DownloadQueWrapper(
      downloadQues: downloadQues ?? this.downloadQues,
      state: state ?? this.state,
      currentQue: currentQue == undefined
          ? null
          : currentQue == null
              ? this.currentQue
              : (currentQue as DownloadQue),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['DownloadQue'] = downloadQues.map((v) => v.toJson()).toList();
    return data;
  }
}

class DownloadQueNotifier extends StateNotifier<DownloadQueWrapper> {
  DownloadQueNotifier() : super(const DownloadQueWrapper());

  Future<void> init() async {
    final res = await DownloadQueRepo.getCurrent();
    if (res.state == NetworkState.success) {
      if ((res.data as List<DownloadQue>).isNotEmpty) {
        state =
            state.copyWith(currentQue: (res.data as List<DownloadQue>).first);
      }
    }
    final res1 = await DownloadQueRepo.getAll();
    if (res1.state == NetworkState.success) {
      if ((res1.data as List<DownloadQue>).isNotEmpty) {
        state = state.copyWith(downloadQues: (res1.data as List<DownloadQue>));
      }
    }
    SharedPreferences.getInstance().then((value) {
      final paused = value.getBool("paused");
      if (paused != null && paused) {
        state = state.copyWith(state: DownloadQueState.paused);
      }
    });
  }

  Future<void> updateProgress(int progress, BuildContext context
      //  T Function<T>(ProviderBase<Object?, T>) read
      ) async {
    if (state.currentQue != null && state.currentQue!.progress != -10) {
      if (progress == 100) {
        state = state.copyWith(
            currentQue: state.currentQue!.copyWith(progress: -10));
        //TODO add to downloaded series
        await context.read(downloadedSeriesProvider.notifier).addDownloadSeries(
            state.currentQue!.anime, state.currentQue!.episode);

        await downloadNextQue();
      } else {
        if (progress >= 0) {
          if (state.currentQue!.fileSize == "failed") {
            state = state.copyWith(
                currentQue: state.currentQue!.copyWith(fileSize: ""));
          }
          state = state.copyWith(
              currentQue: state.currentQue!.copyWith(progress: progress));
        }
      }
    }
  }

  Future<NetworkResult> finishCurrentDownload() async {
    try {
      if (state.currentQue != null) {
        await DownloadQueRepo.deleteCurrent(state.currentQue!);
      }
      state = state.copyWith(currentQue: undefined);

      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> failedDownload() async {
    try {
      state = state.copyWith(
          currentQue: state.currentQue!.copyWith(fileSize: "failed"));

      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> downloadNextQue() async {
    try {
      await finishCurrentDownload();
      if (state.downloadQues.isNotEmpty) {
        final newQue = [...state.downloadQues];
        final NetworkResult link = await downloadOneEpisode(
          // newQue.first.anime,
          newQue.first.episode,
          newQue.first.resolution,
        );
        final que = await download(
          anime: newQue.first.anime,
          episode: newQue.first.episode,
          link: link.data,
          resolution: newQue.first.resolution,
        );
        await DownloadQueRepo.delete(newQue.first);

        newQue.removeAt(0);

        await DownloadQueRepo.addCurrent(que);
        state = state.copyWith(
          downloadQues: newQue,
          currentQue: que,
        );
      } else {
        state = state.copyWith(state: DownloadQueState.idle);
      }
      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> addQue({
    required Anime anime,
    required String episodeId,
    required String resolutionLink,
    required String resolution,
    required Episode episode,
  }) async {
    try {
      //////Checking it is already in the Que or downloading
      bool isAlreadyInQue = false;
      // if (state.currentQue != null) {
      //   if (state.currentQue!.anime == anime &&
      //       episodeId == state.currentQue!.episode.id) {
      //     isAlreadyInQue = true;
      //   }
      // }

      // if (!isAlreadyInQue) {
      for (var que in state.downloadQues) {
        if (que.anime == anime && episodeId == que.episode.id) {
          isAlreadyInQue = true;
          break;
        }
      }
      // }

      if (isAlreadyInQue) throw Exception("AlreadyInQue");
      // final NetworkResult res = await animeEpisodeHandler(episodeId);
      // if (res.state == NetworkState.error) throw Exception(res.data);

      ///add Logic
      ///if not downloading anything
      if (state.state == DownloadQueState.idle) {
        // NetworkResult linkRes = await downloadOneEpisode(
        //   anime,
        //   res.data,
        //   resolution ?? Constant.resolution,
        // );
        final que = await download(
          anime: anime,
          episode: episode,
          link: resolutionLink,
          resolution: resolution,
        );
        await DownloadQueRepo.addCurrent(que);

        state = state.copyWith(
          state: DownloadQueState.downloading,
          currentQue: que,
        );
      } else {
        await DownloadQueRepo.add(DownloadQue(
          episode: episode,
          id: "",
          anime: anime,
          progress: 0,
          fileSize: "",
          resolution: resolution,
        ));
        state = state.copyWith(downloadQues: [
          ...state.downloadQues,
          DownloadQue(
              episode: episode,
              id: "",
              anime: anime,
              progress: 0,
              fileSize: "",
              resolution: resolution)
        ]);
      }
      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> removeQue(Anime anime, String episodeId) async {
    try {
      if (state.currentQue == null) throw Exception("Nothing here");

      ///if the removing ep is currentque
      if (state.currentQue!.anime.id == anime.id &&
          episodeId == state.currentQue!.episode.id) {
        FlutterDownloader.cancel(taskId: state.currentQue!.id);
        await downloadNextQue();
      } else {
        final newDownloadQues = [...state.downloadQues];
        for (var que in newDownloadQues) {
          if (que.anime == anime && episodeId == que.episode.id) {
            await DownloadQueRepo.delete(que);
            newDownloadQues.remove(que);
            break;
          }
        }
        state = state.copyWith(downloadQues: newDownloadQues);
      }

      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> removeAllQue() async {
    try {
      FlutterDownloader.cancelAll();

      final res = await DownloadQueRepo.deleteALl();
      if (res.state == NetworkState.success) {
        state = state.copyWith(
          downloadQues: [],
          currentQue: undefined,
          state: DownloadQueState.idle,
        );
      } else {
        throw Exception("Delete Error");
      }
      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> pauseDownload() async {
    try {
      SharedPreferences.getInstance().then((value) {
        value.setBool("paused", true);
      });
      if (state.currentQue == null) throw Exception("No Que");
      await FlutterDownloader.pause(taskId: state.currentQue!.id);
      state = state.copyWith(state: DownloadQueState.paused);

      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }

  Future<NetworkResult> resumeDownload() async {
    try {
      SharedPreferences.getInstance().then((value) {
        value.setBool("paused", false);
      });
      if (state.currentQue == null) throw Exception("No Que");

      final String? taskId =
          await FlutterDownloader.resume(taskId: state.currentQue!.id);
      state = state.copyWith(
        currentQue: state.currentQue!.copyWith(id: taskId),
        state: DownloadQueState.downloading,
      );

      return NetworkResult(state: NetworkState.success, data: null);
    } catch (e) {
      return NetworkResult(state: NetworkState.error, data: "$e");
    }
  }
}
