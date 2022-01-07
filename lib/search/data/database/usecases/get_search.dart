
import 'package:animely/core/constants/constants.dart';
import 'package:hive/hive.dart';

Future<List<String>> getSearch() async {
  final box = await Hive.openBox(Constant.searchDbName);
  final List<String> rTV = [];

  for (var s in box.values) {
    rTV.add(s);
  }
  await box.close();
  return rTV;
}
