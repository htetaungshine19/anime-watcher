// import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/download/presentation/download_screen.dart';
import 'package:animely/filter/presentation/filter_screen.dart';
import 'package:animely/library/presentation/library_screen.dart';
import 'package:animely/navigation/test_screen.dart';
import 'package:animely/recent/presentation/recent_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentIndex = 0;
  final PageController _controller =
      PageController(keepPage: true, initialPage: 0);
  late final List<Widget> screens;

  @override
  void initState() {
    screens = [
      // const TestScreen(),

      const RecentScreen(),
      // const ExploreScreen(),
      const FilterScreen(),
      const LibraryScreen(),
      if (!kIsWeb) const DownloadScreen(),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          return screens.elementAt(index);
        },
        itemCount: screens.length,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) {
            if (value == currentIndex) {
              switch (value) {
                case 0:
                  {
                    context
                        .read(scrollProvider)
                        .sink
                        .add(ScreenToScroll.recent);
                    break;
                  }
                case 1:
                  {
                    context
                        .read(scrollProvider)
                        .sink
                        .add(ScreenToScroll.filter);
                    break;
                  }
                case 2:
                  {
                    context
                        .read(scrollProvider)
                        .sink
                        .add(ScreenToScroll.library);
                    break;
                  }
              }
            } else {
              _controller
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
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.explore), label: "Explore"),
            BottomNavigationBarItem(
                icon: Icon(Icons.filter_alt_outlined), label: "Filter"),
            BottomNavigationBarItem(
                icon: Icon(Icons.video_library), label: "Library"),
            if (!kIsWeb)
              BottomNavigationBarItem(
                  icon: Icon(Icons.download), label: "Downloads"),
          ]),
    );
  }
}
