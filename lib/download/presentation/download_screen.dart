import 'package:animely/core/providers/provider.dart';
import 'package:animely/download/presentation/downloaded/downloaded_screen.dart';
import 'package:animely/download/presentation/downloading/downloading_screen.dart';
import 'package:animely/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final screens = [];
  int currentIndex = 0;

  final PageController _c = PageController(initialPage: 0, keepPage: true);
  @override
  void initState() {
    screens.addAll([
      const DownloadedScreen(),
      const DownloadingScreen(),
    ]);

    super.initState();
  }

  void navigateTo(int value) {
    if (value == currentIndex) {
    } else {
      // context.read(exploreProvider).currentPage = value;
      _c
          .animateToPage(
        value,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
      )
          .then((_) {
        setState(() {
          currentIndex = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Downloads'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return SettingsView(
                          controller: context.read(settingsProvider));
                    },
                  ));
                },
                icon: const Icon(Icons.settings)),
            currentIndex == 1
                ? IconButton(
                    onPressed: () async {
                      await showGeneralDialog(
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AlertDialog(
                            content: const Text(
                                'Are you sure you want to cancel everything?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("No")),
                              TextButton(
                                  onPressed: () async {
                                    await context
                                        .read(downloadQuesProvider.notifier)
                                        .removeAllQue();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Yes"))
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.cancel_rounded),
                  )
                : IconButton(
                    onPressed: () async {
                      await showGeneralDialog(
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AlertDialog(
                            content: const Text(
                                'Are you sure you want to delete everything?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("cancel")),
                              TextButton(
                                  onPressed: () async {
                                    await context
                                        .read(downloadedSeriesProvider.notifier)
                                        .deleteAllDownloadSeries();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("delete"))
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete),
                  )
          ],
        ),
        body: LayoutBuilder(builder: (context, c) {
          return Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: c.maxWidth * 0.45,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                currentIndex != 0 ? Colors.grey : Colors.blue)),
                        onPressed: () {
                          navigateTo(0);
                        },
                        child: const Text('Finished')),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: c.maxWidth * 0.45,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                currentIndex != 1 ? Colors.grey : Colors.blue)),
                        onPressed: () {
                          navigateTo(1);
                        },
                        child: const Text('Downloads Queues')),
                  ),
                  const Spacer(),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  itemBuilder: (context, index) {
                    return screens[index];
                  },
                  controller: _c,
                  itemCount: 2,
                  onPageChanged: (value) {
                    currentIndex = value;
                    setState(() {});
                  },
                ),
              ),
            ],
          );
        }));
  }
}
