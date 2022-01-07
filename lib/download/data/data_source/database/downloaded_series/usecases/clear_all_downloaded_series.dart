import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:hive/hive.dart';

Future<NetworkResult> clearDownloadsDb() async {
  try {
    final box = await Hive.openBox(Constant.downloadDbName);
    await box.clear();
    await box.deleteFromDisk();
    await box.close();
    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}
