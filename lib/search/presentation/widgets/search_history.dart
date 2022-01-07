import 'package:animely/search/presentation/search_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class SearchHistoryList extends StatefulWidget {
  final Function(String) a;
  const SearchHistoryList({Key? key, required this.a}) : super(key: key);

  @override
  State<SearchHistoryList> createState() => _SearchHistoryListState();
}

class _SearchHistoryListState extends State<SearchHistoryList> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        final l = watch(searchHistoryProvider).reversed;
        return ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(l.elementAt(index)),
              trailing: const Icon(Icons.north_west),
              onTap: () {
                widget.a(l.elementAt(index));
              },
              onLongPress: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      actions: [
                        TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            child: const Text("No")),
                        TextButton(
                            onPressed: () async {
                              await context
                                  .read(searchHistoryProvider.notifier)
                                  .removeHistory(l.elementAt(index));
                              Navigator.pop(context);
                            },
                            child: const Text("Yes")),
                      ],
                      title: const Text(
                          "Are you sure you want to delete this search?"),
                    );
                  },
                );
                setState(() {});
              },
            );
          },
          itemCount: l.length,
        );
      },
    );
  }
}
