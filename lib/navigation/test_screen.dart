import 'dart:typed_data';

import 'package:animely/core/api/api.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/episode.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/recent/data/network/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class FlutterAndroidPip {
  static const MethodChannel _channel = MethodChannel('flutter_android_pip');

  static void enterPictureInPictureMode() {
    _channel.invokeMethod('enterPictureInPictureMode');
  }
}

Future<NetworkResult> _getByteArrayFromUrl(String url) async {
  try {
    final http.Response response = await http.get(Uri.parse(url));
    return NetworkResult<Uint8List>(
        state: NetworkState.success, data: response.bodyBytes);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}

Future<void> _showBigPictureNotificationURL(Anime anime) async {
  final ba = await _getByteArrayFromUrl(anime.img);
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'big text channel id',
    'big text channel name',
    "",
    largeIcon: ba.state == NetworkState.success
        ? ByteArrayAndroidBitmap(ba.data)
        : null,
    autoCancel: true,
    playSound: true,
    groupKey: "new episode",
    onlyAlertOnce: true,
  );
  final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await FlutterLocalNotificationsPlugin().show(
    DateTime.now().second,
    anime.title,
    "Episode - ${anime.totalEpisodes}",
    platformChannelSpecifics,
    payload: anime.id,
  );
}

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("screen 1"),
      ),
      body: Center(
        child: Column(
          children: [
            // ElevatedButton(
            //     child: Text("download"),
            //     onPressed: () async {
            //       await _showBigPictureNotificationURL(
            //         const Anime(
            //           title: "one piece",
            //           img: 'https://via.placeholder.com/400x800',
            //           id: "one-piece",
            //           isFullInfo: true,
            //           episodes: [
            //             '180-byou-de-kimi-no-mimi-wo-shiawase-ni-dekiru-ka-episode-3'
            //           ],
            //         ),
            //       );

            //     }),
            ElevatedButton(
                child: Text("show all "),
                onPressed: () {
                  FlutterAndroidPip.enterPictureInPictureMode();

                  // final res = await animeHandler(
                  //     "180-byou-de-kimi-no-mimi-wo-shiawase-ni-dekiru-ka");

                  // final a = (res.data as Anime).copyWith(
                  //     totalEpisodes: (res.data as Anime).totalEpisodes + 1,
                  //     episodes: [
                  //       ...(res.data as Anime).episodes,
                  //       "180-byou-de-kimi-no-mimi-wo-shiawase-ni-dekiru-ka-episode-7"
                  //     ]);
                  // await context
                  //     .read(downloadedSeriesProvider.notifier)
                  //     .updateLibraryAnimeEp(a);
                  // print(a.toJson());
                  // context
                  //     .read(downloadedSeriesProvider.notifier)
                  //     .updateLibraryAnimeEp();
                }),
            // ElevatedButton(
            //     child: Text("delete anime"),
            //     onPressed: () async {
            //       await context
            //           .read(downloadProvider.notifier)
            //           .deleteDownloadedAnime(const Anime(
            //               title: "one piece",
            //               img: "",
            //               id: "180-byou-de-kimi-no-mimi-wo-shiawase-ni-dekiru-ka",
            //               isFullInfo: true));
            //     }),
            // ElevatedButton(
            //     child: Text("delete episode"),
            //     onPressed: () async {
            //       await context
            //           .read(downloadProvider.notifier)
            //           .deleteDownloadedAnimeEpisode(
            //               const Anime(
            //                   title: "one piece",
            //                   img: "",
            //                   id: "180-byou-de-kimi-no-mimi-wo-shiawase-ni-dekiru-ka",
            //                   isFullInfo: true),
            //               "180-byou-de-kimi-no-mimi-wo-shiawase-ni-dekiru-ka-episode-1");
            //     }),
            // ElevatedButton(
            //     child: Text("cancel all"),
            //     onPressed: () async {
            //       await context.read(downloadProvider.notifier).cancelAll();
            //       // print();
            //     }),
            // ElevatedButton(
            //     child: Text("pause"),
            //     onPressed: () async {
            //       await context.read(downloadProvider.notifier).pauseDownload();
            //       // print();
            //     }),
            // ElevatedButton(
            //     child: Text("cancel all"),
            //     onPressed: () async {
            //       await context.read(downloadProvider.notifier).cancelAll();
            //       // print();
            //     }),
            // ElevatedButton(
            //     child: Text("cancel que"),
            //     onPressed: () async {
            //       await context.read(downloadProvider.notifier).removeQueue(
            //           const Anime(
            //               title: "one piece",
            //               img: "",
            //               id:
            //                   "180-byou-de-kimi-no-mimi-wo-shiawase-ni-dekiru-ka",
            //               isFullInfo: true),
            //           Episode(
            //               id: "180-byou-de-kimi-no-mimi-wo-shiawase-ni-dekiru-ka-episode-1",
            //               servers: []));
            //       // print();
            //     }),
          ],
        ),
      ),
    );
  }
}
