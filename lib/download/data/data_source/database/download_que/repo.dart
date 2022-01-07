import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/download.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:hive/hive.dart';

class DownloadQueRepo {
  static Future<NetworkResult> getAll() async {
    return getAllDownloadQue();
  }

  static Future<NetworkResult> deleteALl() async {
    return deleteAllDownloadQues();
  }

  static Future<NetworkResult> add(DownloadQue s) async {
    return addDownloadQue(s);
  }

  static Future<NetworkResult> addCurrent(DownloadQue s) async {
    return addCurrentQue(s);
  }

  static Future<NetworkResult> getCurrent() async {
    return getCurrentQue();
  }

  static Future<NetworkResult> deleteCurrent(DownloadQue s) async {
    return deleteCurrentQue(s);
  }

  static Future<NetworkResult> delete(DownloadQue s) async {
    return deleteDownloadQue(s);
  }
}

Future<NetworkResult> addDownloadQue(DownloadQue s) async {
  try {
    final box = await Hive.openBox(Constant.downlaodqueDbName);
    await box.add(s);

    await box.close();
    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    // print("$e");

    return NetworkResult(state: NetworkState.error, data: '$e');
  }
}

Future<NetworkResult> addCurrentQue(DownloadQue s) async {
  try {
    final box = await Hive.openBox(Constant.currentQue);
    await box.add(s);
    await box.close();
    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: '$e');
  }
}

Future<NetworkResult> deleteDownloadQue(DownloadQue s) async {
  try {
    print("delete");

    final box = await Hive.openBox(Constant.downlaodqueDbName);
    box.toMap().forEach((key, value) async {
      if ((value as DownloadQue).anime.id == s.anime.id &&
          value.episode.id == s.episode.id) {
        await box.delete(key);
      }
    });
    await box.close();
    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}

Future<NetworkResult> deleteCurrentQue(DownloadQue s) async {
  try {
    final box = await Hive.openBox(Constant.currentQue);
    box.toMap().forEach((key, value) async {
      if ((value as DownloadQue).anime.id == s.anime.id) {
        await box.delete(key);
      }
    });
    await box.close();
    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}

Future<NetworkResult> getAllDownloadQue() async {
  try {
    final List<DownloadQue> rv = [];
    final box = await Hive.openBox(Constant.downlaodqueDbName);
    for (var i in box.values) {
      rv.add(i as DownloadQue);
    }
    await box.close();

    return NetworkResult<List<DownloadQue>>(
        state: NetworkState.success, data: rv);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}

Future<NetworkResult> getCurrentQue() async {
  try {
    final List<DownloadQue> rv = [];
    final box = await Hive.openBox(Constant.currentQue);
    for (var i in box.values) {
      rv.add(i as DownloadQue);
    }
    await box.close();
    return NetworkResult<List<DownloadQue>>(
        state: NetworkState.success, data: rv);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}

Future<NetworkResult> deleteAllDownloadQues() async {
  try {
    final box = await Hive.openBox(Constant.downlaodqueDbName);
    await box.clear();
    await box.deleteFromDisk();
    await box.close();
    final box2 = await Hive.openBox(Constant.currentQue);
    await box2.clear();
    await box2.deleteFromDisk();
    await box2.close();

    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}
