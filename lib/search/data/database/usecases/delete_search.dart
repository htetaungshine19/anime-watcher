
import 'package:animely/core/constants/constants.dart';
import 'package:hive/hive.dart';
Future<void> removeS(String s) async {
  final box = await Hive.openBox(Constant.searchDbName);
  box.toMap().forEach((k, element) async {
    if (element.toString() == s) {
      await box.delete(k);
    }
  });
  await box.close();
}
