import 'package:animely/core/api/api.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/library/presentation/library_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// AndroidNotificationDetails noti =const AndroidNotificationDetails("","","",ongoing: true,progress: 0,showProgress: true,);
Future<void> refresh(BuildContext context) async {
  if (!context.read(libraryProvider).isRefreshing) {
    context.read(libraryProvider).changeRefresh(true);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Updating Library")));
    int progress = 0;
    print("refreshing");

    final list = context.read(libraryProvider).list;
    final List<Future> a = [];
    for (var value in list.values) {
      if (value.status.toLowerCase() == "ongoing") {
        a.add(refreshOne(context, value));
      }
    }
    await AndroidFlutterLocalNotificationsPlugin()
        .show(20, "Updating Library($progress/${a.length})", "",
            notificationDetails: AndroidNotificationDetails(
              "channelId",
              "channelName",
              "channelDescription",
              ongoing: true,
              progress: progress,
              maxProgress: a.length,
              showProgress: true,
              enableVibration: false,
              playSound: false,
            ));
    await Future.wait([
      for (var future in a)
        future.whenComplete(() async {
          progress++;
          await AndroidFlutterLocalNotificationsPlugin()
              .show(20, "Updating Library($progress/${a.length})", "",
                  notificationDetails: AndroidNotificationDetails(
                    "channelId",
                    "channelName",
                    "channelDescription",
                    ongoing: true,
                    progress: progress,
                    maxProgress: a.length,
                    showProgress: true,
                    enableVibration: false,
                    playSound: false,
                  ));
        })
    ], eagerError: true);
    context.read(libraryProvider).changeRefresh(false);
    await AndroidFlutterLocalNotificationsPlugin().cancel(20);
  }
}

Future<void> refreshOne(BuildContext context, Anime anime) async {
  final res = await animeHandler(anime.id);
  if (res.state == NetworkState.error) return;
  await context.read(libraryProvider).updateAnimeEp((res.data as Anime));
  await context
      .read(downloadedSeriesProvider.notifier)
      .updateLibraryAnimeEp((res.data as Anime));
}

Future<void> refreshOneLibrary(BuildContext context, Anime anime) async {
  if (!context.read(libraryProvider).isItemInside(anime)) return;

  final int epId = int.parse(anime.title.split("\n").last.split("-").last);
  if (epId > context.read(libraryProvider).getItemInside(anime).totalEpisodes) {
    final res = await animeHandler(anime.id);
    if (res.state == NetworkState.error) return;
    await context.read(libraryProvider).updateAnimeEp((res.data as Anime));
    await context
        .read(downloadedSeriesProvider.notifier)
        .updateLibraryAnimeEp((res.data as Anime));
  }
}
