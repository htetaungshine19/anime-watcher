import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/utils/refresh.dart';
import 'package:animely/core/widgets/anime_detail_screen.dart';
import 'package:animely/core/widgets/anime_grid.dart';
import 'package:animely/library/presentation/library_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with AutomaticKeepAliveClientMixin {
  int pageNum = 1;
  bool fetched = false;
  final _controller = TextEditingController();
  final _key = GlobalKey<AnimeGridState>();
  final FocusNode _focusNode = FocusNode();
  bool keyboardShow = false;
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
        // leading: const Center(
        //   child: Text(
        //     "Library",
        //     style: TextStyle(fontSize: 18),
        //   ),
        // ),
        actions: [
          IconButton(
            onPressed: () async {
              if (!keyboardShow) {
                _focusNode.requestFocus();
              } else {
                _focusNode.unfocus();
              }

              keyboardShow = !keyboardShow;

              setState(() {});
            },
            icon: const Icon(Icons.search),
          ),
          Consumer(builder: (context, w, _) {
            return w(libraryProvider).list.isNotEmpty
                ? IconButton(
                    tooltip: "Delete All",
                    onPressed: () async {
                      final del = await showGeneralDialog(
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AlertDialog(
                            content: const Text(
                                'Are you sure you want to delete everything?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text("cancel")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text("delete"))
                            ],
                          );
                        },
                      );
                      if (del != null && del == true) {
                        await context.read(libraryProvider).deleteAll();
                      }
                    },
                    icon: const Icon(Icons.delete),
                  )
                : const SizedBox();
          })
        ],
        title: Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 1,
            child: Row(
              children: [
                Expanded(
                  child: keyboardShow
                      ? TextFormField(
                          focusNode: _focusNode,
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Library Search",
                            hintStyle: TextStyle(color: Colors.grey.shade300),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) async {
                            setState(() {});
                          },
                          onEditingComplete: () async {
                            keyboardShow = false;
                            setState(() {});

                            _focusNode.unfocus();
                          },
                        )
                      : const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Library"),
                        ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: keyboardShow
                      ? _controller.text.isNotEmpty
                          ? IconButton(
                              onPressed: () async {
                                _controller.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            )
                          : const SizedBox()
                      : const SizedBox(),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer(
        builder: (context, w, c) {
          return c as Widget;
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Consumer(builder: (context, w, _) {
                    final data = w(libraryProvider).list.values.toList();
                    final searchData = <Anime>[];
                    if (_controller.text.isNotEmpty) {
                      for (var i in data) {
                        if (i.title
                            .toLowerCase()
                            .contains(_controller.text.toLowerCase())) {
                          searchData.add(i);
                        }
                      }
                    }
                    if (_controller.text.isEmpty) {
                      searchData.clear();
                      searchData.addAll(data);
                    }
                    Future.delayed(Duration.zero).then((value) {
                      _key.currentState!.onRefresh();
                    });

                    //add filter logic
                    return AnimeGrid(
                      // mark: w(libraryProvider).noti,
                      screenType: ScreenToScroll.library,
                      isOffline: true,
                      key: _key,
                      data: searchData,
                      maxItem: 9999999999,
                      fetch: (page) async {
                        return NetworkResult(
                            state: NetworkState.error, data: []);
                      },
                      onRefresh: () async {
                        refresh(context);
                      },
                      onTap: (index) {
                        context
                            .read(libraryProvider)
                            .removeNoti(searchData[index]);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return ShowAnimeDetail(anime: searchData[index]);
                          },
                        ));
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
