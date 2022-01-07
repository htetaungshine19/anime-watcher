import 'dart:async';

import 'package:animely/download/presentation/downloading/download_que_notifier.dart';
import 'package:animely/download/presentation/downloaded/download_state_notifer.dart';
import 'package:animely/settings/settings_controller.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final internetStateProvider = StreamProvider.autoDispose((ref) {
//   return Connectivity().onConnectivityChanged;
// });
enum ScreenToScroll {
  recent,
  filter,
  library,
  download,
  explore,
  search,
  none,
}
final scrollProvider = Provider((ref) {
  return StreamController.broadcast();
});
final scrollStreamProvider = StreamProvider((ref) {
  return ref.read(scrollProvider).stream;
});

final downloadedSeriesProvider =
    StateNotifierProvider<DownloadedSeriesNotifier, DownloadedSeriesWrapper>(
        (ref) {
  return DownloadedSeriesNotifier();
});

final downloadQuesProvider =
    StateNotifierProvider<DownloadQueNotifier, DownloadQueWrapper>((ref) {
  // return DownloadQueNotifier();
  throw UnimplementedError();
});
final settingsProvider = ChangeNotifierProvider<SettingsController>((_) {
  throw UnimplementedError();
});
