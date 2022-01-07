// import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/widgets/anime_grid.dart';
import 'package:animely/filter/data/network/network.dart';
import 'package:animely/filter/presentation/filter_provider.dart';
import 'package:animely/filter/presentation/widgets/filter_appbar_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with AutomaticKeepAliveClientMixin {
  final _key = GlobalKey<AnimeGridState>();
  // final ScrollController _c = ScrollController();
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter"),
        actions: [
          // IconButton(
          //   tooltip: "search",
          //   onPressed: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => const SearchScreen()));
          //   },
          //   icon: const Icon(Icons.search),
          // ),
          filterAppbarAction(context, () {
            if (_key.currentState != null) _key.currentState!.onRefresh();
          })
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
          return c as Widget;
        },
        child: LayoutBuilder(builder: (context, me) {
          return FractionallySizedBox(
            heightFactor: 1,
            widthFactor: 1,
            child: Center(
              child: Consumer(builder: (context, w, _) {
                final filterObj = w(filterProvider);
                return AnimeGrid(
                  screenType: ScreenToScroll.filter,
                  isOffline: false,
                  key: _key,
                  maxItem: 100,
                  fetch: (page) async {
                    return await filter(
                      format:
                          filterObj.format.isEmpty ? null : filterObj.format,
                      keyword:
                          filterObj.keyword.isEmpty ? null : filterObj.keyword,
                      season:
                          filterObj.seasons.isEmpty ? null : filterObj.seasons,
                      status:
                          filterObj.status.isEmpty ? null : filterObj.status,
                      year: filterObj.year.isEmpty ? null : filterObj.year,
                      page: page.toString(),
                    );
                  },
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
