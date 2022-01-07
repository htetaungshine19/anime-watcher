import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/widgets/anime_detail_screen.dart';
import 'package:animely/core/widgets/anime_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadedScreen extends StatelessWidget {
  const DownloadedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, w, _) {
      final downloadedSeries = w(downloadedSeriesProvider).downloadedSeries;
      final List<Anime> data = [];
      for (var element in downloadedSeries) {
        data.add(element.anime);
      }
      return Scaffold(
        body: downloadedSeries.isEmpty
            ? const Center(
                child: Text(
                'Your Download is Empty.Go and Download Something!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ))
            : AnimeGrid(
                screenType: ScreenToScroll.download,
                fetch: (page) async {
                  return NetworkResult(state: NetworkState.success, data: []);
                },
                isOffline: true,
                data: data,
                onTap: (index) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return ShowAnimeDetail(anime: data.elementAt(index));
                    },
                  ));
                },
                maxItem: 999999999,
              ),
      );
    });
  }
}
