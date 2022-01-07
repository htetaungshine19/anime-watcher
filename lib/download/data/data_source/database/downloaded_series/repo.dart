import 'package:animely/core/models/download.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/download/data/data_source/database/downloaded_series/usecases/add_downloaded_serie.dart';
import 'package:animely/download/data/data_source/database/downloaded_series/usecases/clear_all_downloaded_series.dart';
import 'package:animely/download/data/data_source/database/downloaded_series/usecases/del_downloaded_serie.dart';
import 'package:animely/download/data/data_source/database/downloaded_series/usecases/get_downloaded_series.dart';

class DownloadedSeriesRepo {
  static Future<NetworkResult> getDownloadedSeries() async {
    return getDownloads();
  }

  static Future<NetworkResult> addDownloadedSerie(DownloadedSeries s) async {
    // print("adding to downloaded");
    return addDownload(s);
  }

  static Future<NetworkResult> clearAllDownloadedSeries() async {
    return clearDownloadsDb();
  }

  static Future<NetworkResult> deleteDownloadedSerie(DownloadedSeries s) async {
    // print("deleting from downloaded");

    return delDownload(s);
  }
}
