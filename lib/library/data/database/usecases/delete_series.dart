import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:hive/hive.dart';

Future<NetworkResult> deleteLibrary(Anime a) async {
  try {
    final box = await Hive.openBox(Constant.libraryDbName);

    if (box.containsKey(a.id)) {
      await box.delete(a.id);
    }
    await box.close();
    return NetworkResult(data: null, state: NetworkState.success);
  } catch (e) {
    return NetworkResult<String>(state: NetworkState.error, data: "$e");
  }
}
