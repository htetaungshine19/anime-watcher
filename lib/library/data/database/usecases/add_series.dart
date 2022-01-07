import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/library/data/repo/repo.dart';
import 'package:hive/hive.dart';

Future<NetworkResult> addLibrary(Anime a) async {
  try {
    final box = await Hive.openBox(Constant.libraryDbName);
    if (box.containsKey(a.id)) await LibraryRepo.deleteSeries(a);
    await box.put(a.id, a);
    await box.close();
    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    return NetworkResult<String>(state: NetworkState.error, data: "$e");
  }
}
