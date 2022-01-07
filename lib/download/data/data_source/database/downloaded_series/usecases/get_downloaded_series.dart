import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/download.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:hive/hive.dart';

Future<NetworkResult> getDownloads() async {
  try {
    final List<DownloadedSeries> rv = [];
    final box = await Hive.openBox(Constant.downloadDbName);
    for (var i in box.values) {
      rv.add(i as DownloadedSeries);
    }
    await box.close();
    // print("getting)}");
    // print(rv.length);
    // for (var element in rv) {
      // print(element.toJson());
    // }
    return NetworkResult<List<DownloadedSeries>>(
        state: NetworkState.success, data: rv);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}
