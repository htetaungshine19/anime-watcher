import 'package:animely/core/models/network_return_result.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/episode.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//getDownloadLinks
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Future<NetworkResult> downloadOneEpisode(
     Episode episode, String resolution) async {
  try {
    // Episode ep = await animeEpisodeHandler(l.episodes.elementAt(epId));
    String link = '';
    for (var i in episode.servers) {
      if (i.name == "main") {
        link = i.iframe;
      }
    }

    Map<String, String> links = {};

    final res = await getDownloadLinks(link);
    if (res.state == NetworkState.success) {
      links = res.data;
    } else {
      throw Exception(res.data);
    }
    String dl = "";
    if (links.containsKey(resolution)) {
      dl = links[resolution]!;
    } else {
      dl = links.values.first;
    }
    return NetworkResult<String>(state: NetworkState.success, data: dl);
  } catch (e) {
    return NetworkResult<String>(state: NetworkState.error, data: "$e");
  }
}

Future<NetworkResult> getDownloadLinks(String epLink) async {
  try {
    String _url = epLink;
    if (!_url.startsWith("https://")) {
      _url = "https://" + _url;
    }

    String realURL =
        'https://gogoplay1.com/download?id=${Uri.parse(_url).queryParameters['id']}';
    final res = await http.get(Uri.parse(realURL));
    final $ = parser.parse(res.body);
    final Map<String, String> returnValue = {};
    $
        .querySelectorAll(
            "#main .content .content_c .content_c_bg .mirror_link .dowload a")
        .forEach((element) {
      if (element.text.contains("360")) {
        returnValue['360'] = element.attributes['href']!;
      } else if (element.text.contains("480")) {
        returnValue['480'] = element.attributes['href']!;
      } else if (element.text.contains("720")) {
        returnValue['720'] = element.attributes['href']!;
      } else if (element.text.contains("1080")) {
        returnValue['1080'] = element.attributes['href']!;
      }
    });

    return NetworkResult<Map<String, String>>(
        state: NetworkState.success, data: returnValue);
  } catch (e) {
    return NetworkResult<String>(state: NetworkState.error, data: "$e");
  }
}
