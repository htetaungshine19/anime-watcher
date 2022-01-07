import 'dart:isolate';
import 'dart:ui';

import 'package:animely/core/models/anime.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/widgets/anime_detail_screen.dart';
import 'package:animely/library/presentation/library_provider.dart';
import 'package:animely/navigation/navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ReceivePort _receivePort;

  @override
  void initState() {
    if (!kIsWeb) {
      _receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(
          _receivePort.sendPort, "download_for_gogo");
      _receivePort.listen((message) async {
        DownloadTaskStatus a = message[1] as DownloadTaskStatus;
        print("updating");
        if (a == DownloadTaskStatus.complete && (message[2] as int) < 100) {
          await context.read(downloadQuesProvider.notifier).downloadNextQue();
        }
        if (a == DownloadTaskStatus.failed) {
          await context.read(downloadQuesProvider.notifier).failedDownload();
          //   await context.read(downloadQuesProvider.notifier).pauseDownload();
        }
        await context
            .read(downloadQuesProvider.notifier)
            .updateProgress(message[2] as int, context);
      });

      FlutterDownloader.registerCallback(downloadCallback);
      FlutterLocalNotificationsPlugin().initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('launcher_icon'),
        ),
        onSelectNotification: (payload) async {
          if (payload != null) {
            if (!context.read(libraryProvider).isItemInside(
                Anime(title: "", img: "", id: payload, isFullInfo: false))) {
              return;
            }
            Future.delayed(Duration.zero).then((_) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return ShowAnimeDetail(
                    anime: context.read(libraryProvider).getItemInside(
                          Anime(
                              title: "",
                              img: "",
                              id: payload,
                              isFullInfo: false),
                        ),
                  );
                },
              ));
            });
          }
        },
      );
    }
    super.initState();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (!kIsWeb) {
      final SendPort send =
          IsolateNameServer.lookupPortByName('download_for_gogo')!;
      send.send([id, status, progress]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Navigation();
  }
}
