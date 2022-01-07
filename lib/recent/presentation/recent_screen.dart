import 'package:animely/core/models/anime.dart';
import 'package:animely/core/providers/provider.dart';

// import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/widgets/anime_grid.dart';
import 'package:animely/recent/data/network/network.dart';
import 'package:animely/search/presentation/search_screen.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:visibility_detector/visibility_detector.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({Key? key}) : super(key: key);

  @override
  _RecentScreenState createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen>
    with AutomaticKeepAliveClientMixin {
  int pageNum = 1;
  bool fetched = false;
  // final ScrollController _c = ScrollController();
  final List<Anime> data = [];
  bool called = false;
  @override
  void initState() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent"),
        actions: [
          IconButton(
            tooltip: "search",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchScreen()));
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, w, c) {
          // w(scrollStreamProvider).maybeWhen(
          //   orElse: () {},
          //   error: (error, stackTrace) {},
          //   data: (value) {
          //     if (value.toString() == '0') {
          //       _c.animateTo(0.0,
          //           duration: const Duration(milliseconds: 600),
          //           curve: Curves.ease);
          //     }
          //     context.read(scrollProvider).sink.addError(Error());
          //   },
          // );
          return c!;
        },
        child: LayoutBuilder(builder: (context, me) {
          return FractionallySizedBox(
            heightFactor: 1,
            widthFactor: 1,
            child: AnimeGrid(
              screenType: ScreenToScroll.recent,
              isOffline: false,
              fetch: (page) async {
                return await getRecentEpisodes(page);
              },
            ),
          );
        }),
      ),
    );
  }
}
