import 'package:animely/filter/domain/models/filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filterProvider = ChangeNotifierProvider((_) {
  return Filter();
});