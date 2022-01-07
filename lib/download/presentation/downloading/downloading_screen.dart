import 'package:animely/core/models/download.dart';
import 'package:animely/core/models/que_state.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadingScreen extends StatelessWidget {
  const DownloadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, w, _) {
      List<DownloadQue> queues = [...w(downloadQuesProvider).downloadQues];
      if (w(downloadQuesProvider).currentQue != null) {
        queues = [...queues];
      }
      return Scaffold(
        floatingActionButton: w(downloadQuesProvider).currentQue != null
            ? FloatingActionButton(
                onPressed: () async {
                  if (w(downloadQuesProvider).state ==
                      DownloadQueState.downloading) {
                    await w(downloadQuesProvider.notifier).pauseDownload();
                  } else if (w(downloadQuesProvider).state ==
                      DownloadQueState.paused) {
                    await w(downloadQuesProvider.notifier).resumeDownload();
                  }
                },
                child: Icon(
                    w(downloadQuesProvider).state == DownloadQueState.paused
                        ? Icons.play_arrow
                        : Icons.pause),
                backgroundColor: Colors.blue,
              )
            : null,
        body: SafeArea(
          child: SizedBox(
            child: Column(
              children: [
                if (w(downloadQuesProvider).currentQue != null)
                  DownloadingListTile(
                    key: ObjectKey(w(downloadQuesProvider).currentQue!),
                    downloadQue: w(downloadQuesProvider).currentQue!,
                    currentlyDownloading: true,
                  ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return DownloadingListTile(
                        key: ObjectKey(queues.elementAt(index)),
                        downloadQue: queues.elementAt(index),
                      );
                    },
                    itemCount: queues.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class DownloadingListTile extends StatelessWidget {
  final DownloadQue downloadQue;
  final bool currentlyDownloading;
  const DownloadingListTile({
    Key? key,
    required this.downloadQue,
    this.currentlyDownloading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            downloadQue.anime.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Episode-${downloadQue.episode.id.split('-').last}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      subtitle: currentlyDownloading
          ? LinearProgressIndicator(
              value: downloadQue.progress / 100,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child:
                currentlyDownloading ? Text("${downloadQue.progress}%") : null,
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   mainAxisSize: MainAxisSize.max,
            //   children: currentlyDownloading
            //       ? [

            //           // Text(downloadQue.fileSize),
            //         ]
            //       : [],
            // ),
          ),
          const SizedBox(
            width: 3,
          ),
          IconButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      actions: [
                        TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            child: const Text("No")),
                        TextButton(
                            onPressed: () async {
                              context
                                  .read(downloadQuesProvider.notifier)
                                  .removeQue(downloadQue.anime,
                                      downloadQue.episode.id);

                              Navigator.pop(context);
                            },
                            child: const Text("Yes")),
                      ],
                      title: const Text(
                          "Are you sure you want to delete this que?"),
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
    );
  }
}
