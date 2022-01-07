import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//getRecentEpisodes
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Future<NetworkResult> getRecentEpisodes(int pageNum) async {
  String modifiedUrl = Constant.url + "?page=$pageNum";

  try {
    final res = await http
        .get(
          Uri.parse(modifiedUrl),
        )
        .timeout(const Duration(seconds: 10));

    List<Anime> returnValue = [];
    final $ = parser.parse(res.body);
    $
        .querySelector('#load_recent_release')!
        .querySelectorAll('div.last_episodes ul li')
        .asMap()
        .forEach((key, value) {
      String img = "";
      String name = "";
      String? animeId;
      int episode = 0;
      final a = value.querySelector(".img a img");
      final b = value.querySelector(".episode");
      if (a != null) {
        img = (a.attributes['src']!);
        name = (a.attributes['alt']!);
      }
      if (b != null) {
        final regexp = RegExp(r'\d+');
        episode = int.parse(regexp.firstMatch(b.innerHtml)!.group(0)!);
      }
      final c = value.querySelector(".name a");
      if (c != null) {
        animeId = c.attributes['href']!.split('/').last;
        if (animeId.contains("episode")) {
          animeId = animeId.replaceAll(RegExp(r"-episode-.+"), "");
        }
      }
      returnValue.add(Anime(
        title: "$name\nEpisode-$episode",
        img: img,
        isFullInfo: false,
        id: animeId ?? "",
      ));
    });
    return NetworkResult<List<Anime>>(
        state: NetworkState.success, data: returnValue);
  } catch (e) {
    // print(e);
    return NetworkResult<String>(data: "$e", state: NetworkState.error);
  }
}
