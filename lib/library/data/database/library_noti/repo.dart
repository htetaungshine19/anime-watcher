import 'package:animely/core/models/network_return_result.dart';
import 'package:hive/hive.dart';

class NotiRepo {
  static Future<NetworkResult> addNoti(String key, String value) async {
    return addNotiDb(key, value);
  }

  static Future<NetworkResult> getNoti() async {
    return getNotiDb();
  }

  static Future<NetworkResult> deleteNoti(String s) async {
    return deleteCurrentQue(s);
  }
}

Future<NetworkResult> addNotiDb(String key, String value) async {
  try {
    final box = await Hive.openBox("notitest");
    await box.put(key, value);
    await box.close();
    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: '$e');
  }
}

Future<NetworkResult> deleteCurrentQue(String key) async {
  try {
    final box = await Hive.openBox("notitest");
    box.delete(key);
    await box.close();
    return NetworkResult(state: NetworkState.success, data: null);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}

Future<NetworkResult> getNotiDb() async {
  try {
    final Map<String, String> rv = {};
    final box = await Hive.openBox("notitest");
    box.toMap().forEach((key, value) {
      rv[key] = value;
    });
    await box.close();
    return NetworkResult<Map<String, String>>(
        state: NetworkState.success, data: rv);
  } catch (e) {
    return NetworkResult(state: NetworkState.error, data: "$e");
  }
}
