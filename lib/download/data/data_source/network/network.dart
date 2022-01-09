import 'dart:convert';

import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/episode.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
        'https://gogoplay.io/download?id=${Uri.parse(_url).queryParameters['id']}';
    // final res = await http.get(Uri.parse(realURL));

    // final $ = parser.parse(res.body);
    // final Map<String, String> returnValue = {};

    // $
    //     .querySelectorAll(
    //         "#main .content .content_c .content_c_bg .mirror_link .dowload a")
    //     .forEach((element) {
    //   print(element);
    //   if (element.text.contains("360")) {
    //     returnValue['360'] = element.attributes['href']!;
    //   } else if (element.text.contains("480")) {
    //     returnValue['480'] = element.attributes['href']!;
    //   } else if (element.text.contains("720")) {
    //     returnValue['720'] = element.attributes['href']!;
    //   } else if (element.text.contains("1080")) {
    //     returnValue['1080'] = element.attributes['href']!;
    //   }
    // });
    // final Map<String, String> returnValue =
    await Future.delayed(Duration.zero);
    final Map<String, String> returnValue =
        await Constant.key.currentState!.push(PageRouteBuilder(
      opaque: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return LoadingWeb(url: realURL);
      },
    ));
    await Future.delayed(Duration.zero);
    print(returnValue);
    return NetworkResult<Map<String, String>>(
        state: NetworkState.success, data: returnValue);
  } catch (e) {
    return NetworkResult<String>(state: NetworkState.error, data: "$e");
  }
}

// Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2869.0 Safari/537.36
String fakeUserAgent() {
  String a = faker.internet.userAgent();
  if (a.contains("Chrome/")) {
    if (int.parse(a.split("Chrome/").last.split(".").first) > 50) {
      return a;
    } else {
      return fakeUserAgent();
    }
  } else {
    return fakeUserAgent();
  }
}

class LoadingWeb extends StatelessWidget {
  late WebViewController _controller;
  String url;
  LoadingWeb({Key? key, required this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0),
      body: Column(
        children: [
          SizedBox(
            width: 1,
            height: 1,
            child: WebView(
              userAgent: fakeUserAgent()
              // "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36"
              ,
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
              onPageFinished: (String url) async {
                final str = await _controller.runJavascriptReturningResult(
                    "window.document.body.innerHTML");
                final $ = parser.parse(json.decode(str));
                final Map<String, String> returnValue = {};
                $
                    .querySelectorAll(
                        "#main .content .content_c .content_c_bg .mirror_link .dowload a")
                    .forEach((element) {
                  // print(element);
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
                print(returnValue);
                await Future.delayed(Duration.zero);
                Navigator.of(context).pop(returnValue);
              },
            ),
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }
}
