import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/library/data/database/usecases/add_series.dart';
import 'package:animely/library/data/database/usecases/delete_all_series.dart';
import 'package:animely/library/data/database/usecases/delete_series.dart';
import 'package:animely/library/data/database/usecases/get_added_series.dart';

class LibraryRepo {
  static Future<NetworkResult> getAddedSeries() async {
    return getLibrary();
  }

  static Future<NetworkResult> addSeries(Anime a) async {
    return addLibrary(a);
  }

  static Future<NetworkResult> deleteSeries(Anime a) async {
    return deleteLibrary(a);
  }

  static Future<NetworkResult> deleteAllSeries() async {
    return deleteAllLibrary();
  }
}
