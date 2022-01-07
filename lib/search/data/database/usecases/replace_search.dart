import 'package:animely/core/constants/constants.dart';
import 'package:hive/hive.dart';

Future<void> replace(String s) async {
  final box = await Hive.openBox(Constant.searchDbName);
  await box.deleteAt(0);
  await box.add(s);
  await box.close();
}
