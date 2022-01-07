import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/widgets/anime_grid.dart';
import 'package:animely/search/data/network/network.dart';
import 'package:animely/search/presentation/search_notifier.dart';
import 'package:animely/search/presentation/widgets/search_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ValueKey _k = const ValueKey("");
  final TextEditingController _controller = TextEditingController();
  String ht = "";
  bool show = false;
  // SearchLists? s;

  void oT(String a) {
    if (a.isNotEmpty) {
      context.read(searchHistoryProvider.notifier).addToHistory(a).then((_) {
        FocusScope.of(context).requestFocus(FocusNode());
        show = true;
        _controller.text = a;
        setState(() {
          _k = ValueKey(a);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Navigator.of(context).canPop()
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back))
                    : const SizedBox(
                        width: 20,
                      ),
                Expanded(
                    child: TextFormField(
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: ht.isEmpty ? "Search" : "Enter Something",
                    hintStyle:
                        TextStyle(color: ht.isNotEmpty ? Colors.red : null),
                    border: InputBorder.none,
                  ),
                  onTap: () {
                    setState(() {
                      show = false;
                      ht = "";
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      ht = "";
                    });
                  },
                  onEditingComplete: () {
                    if (_controller.text.isNotEmpty) {
                      context
                          .read(searchHistoryProvider.notifier)
                          .addToHistory(_controller.text)
                          .then((_) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        show = true;
                        setState(() {
                          _k = ValueKey(_controller.text);
                        });
                      });
                    } else {
                      setState(() {
                        ht = "1";
                      });
                    }
                  },
                )),
                if (_controller.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.text = "";
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                IconButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      context
                          .read(searchHistoryProvider.notifier)
                          .addToHistory(_controller.text)
                          .then((_) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        show = true;
                        setState(() {
                          _k = ValueKey(_controller.text);
                        });
                      });
                    } else {
                      setState(() {
                        ht = "1";
                      });
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            Expanded(
              child: show
                  ? AnimeGrid(
                      screenType: ScreenToScroll.search,
                      isOffline: false,
                      key: _k,
                      fetch: (page) async {
                        return await search(
                            context.read(searchHistoryProvider).last, page);
                      },
                    )
                  : Consumer(builder: (context, w, _) {
                      w(searchHistoryProvider);
                      return SearchHistoryList(
                        a: oT,
                      );
                    }),
            ),
          ],
        ),
      ),
    );
  }
}
