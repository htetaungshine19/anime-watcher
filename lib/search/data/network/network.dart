import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SEARCH
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Future<NetworkResult> search(String keyword, int page) async {
  try {
    //prepare
    final res = await http.get(
        Uri.parse(Constant.url + "/search.html?keyword=$keyword&page=$page"));
    final body = res.body;
    final $ = parser.parse(body);
    final List<Anime> returnValue = [];

    /////logic
    $
        .querySelector('.main_body')!
        .querySelectorAll('.last_episodes ul li')
        .forEach((value) {
      String? img;
      String? title;
      String? otherName;

      final a = value.querySelector(".img a img");

      if (a != null) {
        img = (a.attributes['src']!);
        title = (a.attributes['alt']!);
      }
      final b = value.querySelector(".name a");
      if (b != null) {
        otherName = b.attributes['href']!.split('/').last;
      }
      returnValue.add(
        Anime(
          title: title!,
          img: img!,
          id: otherName!,
          isFullInfo: false,
        ),
      );
    });
    return NetworkResult<List<Anime>>(
        state: NetworkState.success, data: returnValue);
  } catch (e) {
    return NetworkResult<String>(state: NetworkState.error, data: '$e');
  }
}
