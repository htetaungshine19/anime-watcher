import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:hive/hive.dart';

Future<NetworkResult> getLibrary() async {
  try {
    Map<String, Anime> returnValue = {};
    final box = await Hive.openBox(Constant.libraryDbName);

    box.toMap().forEach((key, value) {
      returnValue['$key'] = value as Anime;
    });

    await box.close();
    return NetworkResult<Map<String, Anime>>(
        state: NetworkState.success, data: returnValue);
  } catch (e) {
    return NetworkResult<String>(state: NetworkState.error, data: "$e");
  }
}
