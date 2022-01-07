import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/episode.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/download/data/data_source/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Stream Links
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Future<NetworkResult> getStreamLink(Episode ep) async {
  String link1 = '';
  for (var i in ep.servers) {
    if (i.name == "main") {
      link1 = i.iframe;
    }
  }
  if (link1.isEmpty) throw Exception("No Link");
  if (!link1.startsWith("https://")) {
    link1 = "https://" + link1;
  }

  http.get(Uri.parse(link1));
  try {
    final realURL = link1;
    final res = await http.get(Uri.parse(realURL));

    Episode returnValue = ep;
    final rp =
        RegExp(r"https:\/\/.+\.m3u8", caseSensitive: false, multiLine: true);
    if (rp.allMatches(res.body).isEmpty) {
      final link = await downloadOneEpisode(ep, "480");
      if (link.state == NetworkState.error) throw Exception();
      List<Servers> servers = ep.servers;
      servers.add(Servers(name: "stream_link", iframe: link.data as String));
      returnValue = ep.copyWith(servers: servers, type: EpisodeType.network);
      return NetworkResult<Episode>(
          state: NetworkState.success, data: returnValue);
    } else {
      for (var element in rp.allMatches(res.body)) {
        List<Servers> servers = ep.servers;
        servers.add(Servers(name: "stream_link", iframe: element.group(0)!));
        returnValue = ep.copyWith(servers: servers, type: EpisodeType.network);
        break;
      }
      return NetworkResult<Episode>(
          state: NetworkState.success, data: returnValue);
    }
  } catch (e) {
    return NetworkResult(data: "$e", state: NetworkState.error);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//animeEpisodeHandler
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Future<NetworkResult> animeEpisodeHandler(String id) async {
  try {
    final res = await http.get(Uri.parse(Constant.url + '/$id'));
    final body = res.body;
    final $ = parser.parse(body);
    final List<Servers> servers = [];
    $.querySelectorAll('div#wrapper_bg').asMap().forEach((index, element) {
      final $element = element;
      $element
          .querySelectorAll('div.anime_muti_link ul li')
          .asMap()
          .forEach((j, el) {
        final $el = el;
        String? name = $el
            .querySelector('a')!
            .text
            .substring(0, $el.querySelector('a')!.text.lastIndexOf('C'))
            .trim();
        var iframe = $el.querySelector('a')!.attributes['data-video'];
        if (iframe!.startsWith('//')) {
          iframe =
              $el.querySelector('a')!.attributes['data-video']!.substring(2);
          if (iframe.contains("embedplus")) {
            name = "main";
          }
        }
        servers.add(Servers(name: name, iframe: iframe));
      });
    });
    return NetworkResult<Episode>(
        state: NetworkState.success,
        data: Episode(id: id, servers: servers, type: EpisodeType.iframe));
  } catch (e) {
    return NetworkResult(data: "$e", state: NetworkState.error);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//animeHandler
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Future<NetworkResult> animeHandler(String id) async {
  try {
    //prepare
    final res = await http.get(Uri.parse('${Constant.url}category/$id'));
    final body = res.body;
    final $ = parser.parse(body);
    final animeInfo = $.querySelector(".anime_info_body_bg")!;

    ///values
    final img = animeInfo.querySelector("img")!.attributes['src'];
    final title = animeInfo.querySelector("h1")!.text;
    final totalEpisode = int.tryParse($
        .querySelectorAll(".anime_video_body #episode_page li")
        .last
        .text
        .trim()
        .split("-")
        .last);
    String? status;
    final List<String> episodes = [];
    String? synopsis;
    String? otherName;
    int? released;
    List<String>? genres = [];

    //logic
    if (totalEpisode != null) {
      for (var i = 0; i < totalEpisode; i++) {
        episodes.add("$id-episode-${i + 1}");
      }
    }

    animeInfo.querySelectorAll('.type').forEach((element) {
      final type = element.querySelector("span")!.text;
      if (type.toLowerCase().contains("summary")) {
        synopsis = element.text.split("\n").last;
      } else if (type.toLowerCase().contains("status")) {
        status = element.querySelector("a")!.text;
      } else if (type.toLowerCase().contains("released")) {
        released =
            int.tryParse(element.text.replaceAll('"', "").split(" ").last);
      } else if (type.toLowerCase().contains("other name")) {
        otherName = element.text.replaceAll("Other name:", "");
      } else if (type.toLowerCase().contains("genre")) {
        final geLi = element.querySelectorAll("a");
        for (var element in geLi) {
          if (element.attributes['title'] != null) {
            genres.add(element.attributes['title']!);
          }
        }
      }
    });

    return NetworkResult<Anime>(
        state: NetworkState.success,
        data: Anime(
          episodes: episodes,
          id: id,
          img: img ?? "",
          title: title,
          totalEpisodes: totalEpisode ?? 0,
          synopsis: synopsis ?? "",
          status: status ?? "unknown",
          released: released ?? 0,
          otherName: otherName ?? "",
          genres: genres,
          isFullInfo: true,
        ));
  } catch (e) {
    return NetworkResult<String>(state: NetworkState.error, data: "$e");
  }
}
