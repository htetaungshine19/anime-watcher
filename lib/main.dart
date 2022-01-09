import 'dart:io';

import 'package:animely/app.dart';
import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/download.dart';
import 'package:animely/core/models/episode.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/download/presentation/downloading/download_que_notifier.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/library/data/database/library_noti/repo.dart';
import 'package:animely/library/data/repo/repo.dart';
import 'package:animely/library/presentation/library_provider.dart';
import 'package:animely/search/data/database/repo.dart';
import 'package:animely/search/presentation/search_notifier.dart';
import 'package:animely/settings/settings_controller.dart';
import 'package:animely/settings/settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:animely/core/models/anime.dart';
import 'package:path_provider/path_provider.dart';

Future<void> init() async {
  await Hive.initFlutter();
  if (!kIsWeb) {
    await FlutterDownloader.initialize(debug: false);

    Directory? a = await getExternalStorageDirectory();
    if (a != null) Constant.externalStorageDir = a.path;
  }
  Hive.registerAdapter(AnimeAdapter());
  Hive.registerAdapter(EpisodeAdapter());
  Hive.registerAdapter(DownloadedSeriesAdapter());
  Hive.registerAdapter(ServersAdapter());
  Hive.registerAdapter(EpisodeTypeAdapter());
  Hive.registerAdapter(DownloadQueAdapter());
}

void main() async {
  await init();
  Map<String, Anime> libraryData = {};
  final res = await LibraryRepo.getAddedSeries();
  if (res.state == NetworkState.success) {
    libraryData.addAll(res.data);
  }
  final downloadQueNoti = DownloadQueNotifier();
  await downloadQueNoti.init();

  Map<String, String> notidata = {};
  final res1 = await NotiRepo.getNoti();

  if (res1.state == NetworkState.success) {
    notidata.addAll(res1.data);
  }
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  runApp(
    ProviderScope(
      child: Consumer(builder: (context, w, _) {
        return MaterialApp(
          navigatorKey: Constant.key,
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',
          onGenerateTitle: (BuildContext context) => "",
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: w(settingsProvider).themeMode,
          home: const MyApp(),
        );
      }),
      overrides: [
        searchHistoryProvider.overrideWithValue(
            SearchHistory(await SearchRepo.getSearchHistory())),
        libraryProvider.overrideWithValue(Library(libraryData, notidata)),
        downloadQuesProvider.overrideWithValue(downloadQueNoti),
        settingsProvider.overrideWithValue(settingsController),
      ],
    ),
  );
}
