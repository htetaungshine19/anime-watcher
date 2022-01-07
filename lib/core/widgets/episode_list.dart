import 'package:animely/core/api/api.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/episode.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/utils/loading.dart';
import 'package:animely/core/utils/show_snackbar.dart';

import 'package:animely/core/widgets/video_player.dart';
import 'package:animely/download/data/data_source/network/network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum NavType { replace, push }

class EpisodeList extends StatefulWidget {
  final Anime anime;
  final int currentEpisodeId;
  final NavType navType;
  const EpisodeList({
    Key? key,
    required this.anime,
    required this.currentEpisodeId,
    required this.navType,
  }) : super(key: key);

  @override
  _EpisodeListState createState() => _EpisodeListState();
}

class _EpisodeListState extends State<EpisodeList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: false,
      itemCount: widget.anime.totalEpisodes,
      itemBuilder: (context, index) {
        return Consumer(builder: (context, w, _) {
          final downloadedSeries = w(downloadedSeriesProvider).downloadedSeries;
          bool downloaded = false;
          Episode? downloadedEpisode;
          bool currentlyDownloading = false;
          for (var element in downloadedSeries) {
            if (element.anime.id == widget.anime.id) {
              for (var i in element.downloadedEpisode) {
                if (i.id == widget.anime.episodes.elementAt(index)) {
                  downloaded = true;
                  downloadedEpisode = i;
                  break;
                }
              }
              break;
            }
          }
          if (w(downloadQuesProvider).currentQue != null) {
            final currentDownload = w(downloadQuesProvider).currentQue!;
            if (currentDownload.anime.id == widget.anime.id &&
                currentDownload.episode.id ==
                    widget.anime.episodes.elementAt(index)) {
              currentlyDownloading = true;
            }
          }
          return EpisodeListTile(
            currentlySelected: index == widget.currentEpisodeId,
            currentlyDownloading: currentlyDownloading,
            downloaded: downloaded,
            navType: widget.navType,
            currentIndex: index,
            anime: widget.anime,
            episode: downloadedEpisode,
            percentage: currentlyDownloading
                ? w(downloadQuesProvider).currentQue!.progress
                : 0,
          );
        });
      },
    );
  }
}

class EpisodeListTile extends StatelessWidget {
  final bool currentlySelected;
  final bool currentlyDownloading;
  final int percentage;
  final bool downloaded;
  final int currentIndex;
  final Anime anime;
  final Episode? episode;
  final NavType navType;
  const EpisodeListTile({
    Key? key,
    required this.currentlySelected,
    required this.currentlyDownloading,
    required this.downloaded,
    required this.navType,
    required this.currentIndex,
    required this.anime,
    required this.episode,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: currentlySelected ? Colors.blue : null,
      trailing: currentlyDownloading
          ? SizedBox(
              width: 20,
              height: 20,
              child: Center(
                  child: CircularProgressIndicator(
                value: percentage / 100,
              )),
            )
          : kIsWeb
              ? null
              : IconButton(
                  icon: Icon(downloaded ? Icons.done : Icons.download),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(0),
                  onPressed: () async {
                    if (downloaded) {
                      bool del = false;
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                                "Are you sure you want to delete this episode?"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    del = false;
                                    Navigator.pop(context);
                                  },
                                  child: const Text('cancel')),
                              TextButton(
                                  onPressed: () {
                                    del = true;
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Ok')),
                            ],
                          );
                        },
                      );

                      if (del == true) {
                        loading(
                            context,
                            context
                                .read(downloadedSeriesProvider.notifier)
                                .deleteEpisodeOfDownloadedSeries(anime,
                                    anime.episodes.elementAt(currentIndex)));
                      }
                    } else {
                      final status = await Permission.storage.request();
                      if (status.isGranted) {
                        final onlineEpisode = await loading(
                            context,
                            animeEpisodeHandler(
                                anime.episodes.elementAt(currentIndex)));
                        if (onlineEpisode.state == NetworkState.error) return;
                        String link = '';
                        for (var i in onlineEpisode.data.servers) {
                          if (i.name == "main") {
                            link = i.iframe;
                          }
                        }
                        if (link.isEmpty) return;
                        final res =
                            await loading(context, getDownloadLinks(link));
                        if (res.state == NetworkState.error) return;
                        final resolutionMaps =
                            (res.data as Map<String, String>);
                        if (resolutionMaps.isEmpty) return;
                        // print(resolutionMaps);
                        String resolution = "480";
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              backgroundColor: Colors.transparent,
                              children: [
                                ...resolutionMaps.keys
                                    .map((e) => ElevatedButton(
                                          onPressed: () {
                                            resolution = e;

                                            Navigator.pop(context);
                                          },
                                          child: Text("${e}p"),
                                        )),
                              ],
                            );
                          },
                        );
                        // print(resolutionMaps[resolution]);
                        // print(resolution);

                        await loading(
                            context,
                            context.read(downloadQuesProvider.notifier).addQue(
                                  anime: anime,
                                  episodeId:
                                      anime.episodes.elementAt(currentIndex),
                                  resolutionLink: resolutionMaps[resolution] ??
                                      resolutionMaps.values.first,
                                  resolution: resolution,
                                  episode: onlineEpisode.data,
                                ));
                      } else {
                        showSnackBar(context, 'permission denied');
                      }
                    }
                  },
                ),
      title: Text('Ep${currentIndex + 1}'),
      onTap: () async {
        if (!kIsWeb) {
          if (currentlySelected) return;
          if (downloaded) {
            switch (navType) {
              case NavType.push:
                {
                  await Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, a, _) {
                      return VideoPlayer(
                        anime: anime,
                        currentEpisode: episode!,
                        episodeId: currentIndex,
                      );
                    },
                  ));
                  break;
                }
              case NavType.replace:
                {
                  await Navigator.of(context).pushReplacement(PageRouteBuilder(
                    pageBuilder: (context, a, _) {
                      return VideoPlayer(
                        anime: anime,
                        currentEpisode: episode!,
                        episodeId: currentIndex,
                      );
                    },
                  ));
                  break;
                }
            }
            return;
          }

          final onlineEpisode = await loading(context,
              animeEpisodeHandler(anime.episodes.elementAt(currentIndex)));
          if (onlineEpisode.state != NetworkState.error) {
            final ll = await loading(
                context, getStreamLink((onlineEpisode.data as Episode)));

            if (ll.state != NetworkState.error) {
              print(ll.data.toJson());
              switch (navType) {
                case NavType.push:
                  {
                    await Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, a, _) {
                        return VideoPlayer(
                          anime: anime,
                          currentEpisode: ll.data,
                          episodeId: currentIndex,
                        );
                      },
                    ));
                    break;
                  }
                case NavType.replace:
                  {
                    await Navigator.of(context)
                        .pushReplacement(PageRouteBuilder(
                      pageBuilder: (context, a, _) {
                        return VideoPlayer(
                          anime: anime,
                          currentEpisode: ll.data,
                          episodeId: currentIndex,
                        );
                      },
                    ));
                    break;
                  }
              }
            }
          } else {
            showSnackBar(context, "Link Failed Please Try Again");
          }
        } else {
          final onlineEpisode = await loading(context,
              animeEpisodeHandler(anime.episodes.elementAt(currentIndex)));
          if (onlineEpisode.state == NetworkState.error) return;
          switch (navType) {
            case NavType.push:
              {
                await Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, a, _) {
                    return VideoPlayer(
                      anime: anime,
                      currentEpisode: onlineEpisode.data,
                      episodeId: currentIndex,
                    );
                  },
                ));
                break;
              }
            case NavType.replace:
              {
                await Navigator.of(context).pushReplacement(PageRouteBuilder(
                  pageBuilder: (context, a, _) {
                    return VideoPlayer(
                      anime: anime,
                      currentEpisode: onlineEpisode.data,
                      episodeId: currentIndex,
                    );
                  },
                ));
                break;
              }
          }
        }
      },
    );
  }
}
