import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/utils/refresh.dart';
import 'package:animely/core/widgets/anime_grid_item.dart';
import 'package:animely/library/presentation/library_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimeGrid extends StatefulWidget {
  final Future<NetworkResult> Function(int page) fetch;
  final Future<void> Function()? onRefresh;
  final ScreenToScroll screenType;
  final int maxItem;
  final void Function(int index)? onTap;
  final List<Anime> data;
  final bool isOffline;
  // final Map<String, String>? mark;
  const AnimeGrid({
    Key? key,
    required this.fetch,
    required this.screenType,
    this.maxItem = 20,
    this.onTap,
    this.onRefresh,
    // this.mark,
    required this.isOffline,
    this.data = const [],
  }) : super(key: key);
  @override
  State<AnimeGrid> createState() => AnimeGridState();
}

class AnimeGridState extends State<AnimeGrid> {
  final ScrollController _scrollController = ScrollController();
  bool hasPage = true;
  List<Anime> data = [];
  int currentPage = 1;
  bool fetching = false;

  Future<void> onRefresh() async {
    setState(() {
      data.clear();
      currentPage = 1;
      hasPage = true;
      data.addAll(widget.data);
      // _scrollController.jumpTo(0);
    });
  }

  void _onVisibilityChanged(VisibilityInfo info) async {
    if (widget.isOffline) {
      hasPage = false;
      await Future.delayed(Duration.zero).then((value) => setState(() {}));
      return;
    }
    final networkstate = await Connectivity().checkConnectivity();
    if (networkstate == ConnectivityResult.none) {
      await Future.delayed(const Duration(seconds: 5));
      _onVisibilityChanged(info);
      return;
    }
    if (info.visibleFraction > 0.2) {
      if (fetching) return;
      fetching = true;
      final fetchedData = await widget.fetch(currentPage);
      if (fetchedData.state == NetworkState.error) {
        await Future.delayed(const Duration(seconds: 5));
        fetching = false;
        _onVisibilityChanged(info);
        return;
      }
      data.addAll(fetchedData.data as List<Anime>);
      currentPage++;
      fetching = false;
      if (fetchedData.data.length < widget.maxItem) {
        hasPage = false;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    data.addAll(widget.data);
    hasPage = !widget.isOffline;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh ?? onRefresh,
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer(builder: (context, w, _) {
              w(scrollStreamProvider).maybeWhen(
                orElse: () {},
                error: (error, stackTrace) {},
                data: (value) {
                  if (value == widget.screenType) {
                    _scrollController.animateTo(0.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease);
                  }
                  context.read(scrollProvider).sink.addError(Error());
                },
              );
              return StaggeredGridView.builder(
                controller: _scrollController,
                shrinkWrap: hasPage,
                gridDelegate:
                    SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  staggeredTileCount: hasPage ? data.length + 1 : data.length,
                  staggeredTileBuilder: (index) {
                    if (index == data.length) {
                      return StaggeredTile.count(
                          MediaQuery.of(context).size.width > 600 ? 4 : 2, 0.3);
                    }
                    return const StaggeredTile.count(1, 1.75);
                  },
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  if (index == data.length && hasPage) {
                    return Center(
                      child: VisibilityDetector(
                        onVisibilityChanged: _onVisibilityChanged,
                        key: ObjectKey(data),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                  
                  return AnimeGridItem(
                    screenType: widget.screenType,
                    showLibraryStatus: !widget.isOffline,
                    anime: data.elementAt(index),
                    onTap: widget.onTap != null
                        ? () {
                            widget.onTap!(index);
                          }
                        : null,
                  );
                },
                itemCount: hasPage ? data.length + 1 : data.length,
              );
            }),
          ),
        ),
      ),
    );
  }
}
