import 'dart:typed_data';

import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/library/data/database/library_noti/repo.dart';
import 'package:animely/library/data/repo/repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Library with ChangeNotifier {
  final Map<String, Anime> _list = {};
  final Map<String, String> _noti = {};
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  Map<String, Anime> get list => _list;
  Map<String, String> get noti => _noti;

  Library(Map<String, Anime> l, Map<String, String> no) {
    _list.addAll(l);
    _noti.addAll(no);
  }
  bool isItemInside(Anime a) {
    return _list.containsKey(a.id);
  }

  void changeRefresh(bool a) {
    _isRefreshing = a;
    notifyListeners();
  }

  Anime getItemInside(Anime a) {
    return _list[a.id]!;
  }

  Future<void> addToLibrary(Anime a) async {
    if (!_list.containsKey(a.id)) {
      final res = await LibraryRepo.addSeries(a);
      if (res.state == NetworkState.error) {
        return;
      }
      _list[a.id] = a;
    }
    notifyListeners();
  }

  Future<void> deleteAll() async {
    final res = await LibraryRepo.deleteAllSeries();
    if (res.state == NetworkState.error) {
      return;
    }
    _list.clear();
    notifyListeners();
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
      enableVibration: false,
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

  Future<void> updateAnimeEp(Anime anime) async {
    if (isItemInside(anime)) {
      if (anime.totalEpisodes != _list[anime.id]!.totalEpisodes) {
        _noti[anime.id] =
            (anime.totalEpisodes - _list[anime.id]!.totalEpisodes).toString();
        await NotiRepo.addNoti(anime.id,
            (anime.totalEpisodes - _list[anime.id]!.totalEpisodes).toString());
        await removeFromLibrary(_list[anime.id]!);
        await addToLibrary(anime);
        _list[anime.id] = anime;
        await _showBigPictureNotificationURL(anime);
      }
    }
    notifyListeners();
  }

  Future<void> removeNoti(Anime anime) async {
    _noti.remove(anime.id);
    NotiRepo.deleteNoti(anime.id);
    notifyListeners();
  }

  Future<void> removeFromLibrary(Anime a) async {
    if (_list.containsKey(a.id)) {
      final res = await LibraryRepo.deleteSeries(a);
      if (res.state == NetworkState.error) {
        return;
      }

      _list.remove(a.id);
    }

    notifyListeners();
  }
}

final libraryProvider = ChangeNotifierProvider<Library>((_) {
  throw UnimplementedError();
});
