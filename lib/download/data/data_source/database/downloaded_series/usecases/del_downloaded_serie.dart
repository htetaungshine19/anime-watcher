import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/download.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:hive/hive.dart';

Future<NetworkResult> delDownload(DownloadedSeries s) async {
  try {
    final box = await Hive.openBox(Constant.downloadDbName);
    box.toMap().forEach((key, value) async {
      if ((value as DownloadedSeries).anime.title == s.anime.title) {
        await box.delete(key);
      }
    });
    await box.close();
    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}
