import 'dart:convert';

import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:http/http.dart' as http;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Filter Api
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Future<NetworkResult> filter({
  String? status,
  String? year,
  String? season,
  String? format,
  String? keyword,
  required String page,
}) async {
  String url = "https://api.aniapi.com/v1/anime?";
  List<Anime> returnValue = [];
  url = url + "page=" + page;

  if (status != null) {
    url = url + "&status=" + status;
  }
  if (year != null) {
    url = url + "&year=" + year;
  }
  if (keyword != null) {
    url = url + "&title=" + keyword;
  }
  if (season != null) {
    url = url + "&season=" + season;
  }
  if (format != null) {
    url = url + "&formats=" + format;
  }

  try {
    final res = await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer ${Constant.filterApiKey}",
    });
    // .timeout(const Duration(minutes: 2));

    final Map<String, dynamic> decodedValue = json.decode(res.body);

    if (decodedValue['data'] != null) {
      if (decodedValue['data']['documents'] != null) {
        decodedValue['data']['documents'].forEach((v) {
          returnValue.add(Anime(
            title: v['titles']['en'] ?? "",
            img: v['cover_image'] ?? "",
            id: "",
            isFullInfo: false,
          ));
        });
      }
    }

    return NetworkResult<List<Anime>>(
        state: NetworkState.success, data: returnValue);
  } catch (e) {
    return NetworkResult<String>(state: NetworkState.error, data: "$e");
  }
}
