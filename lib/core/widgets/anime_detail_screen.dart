import 'package:animely/core/models/anime.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/utils/copytoclip.dart';
import 'package:animely/core/utils/refresh.dart';
import 'package:animely/core/utils/show_snackbar.dart';
import 'package:animely/core/widgets/episode_list.dart';
import 'package:animely/library/presentation/library_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowAnimeDetail extends StatefulWidget {
  final Anime anime;

  const ShowAnimeDetail({Key? key, required this.anime}) : super(key: key);

  @override
  State<ShowAnimeDetail> createState() => _ShowAnimeDetailState();
}

class _ShowAnimeDetailState extends State<ShowAnimeDetail> {
  bool isAdded = false;

  @override
  void initState() {
    isAdded = context.read(libraryProvider).list.containsKey(widget.anime.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anime.title),
        actions: [
          IconButton(
            onPressed: () async {
              if (isAdded) {
                await context.read(libraryProvider).removeFromLibrary(
                      widget.anime,
                    );
                showSnackBar(context, "Deleted from Library");
              } else {
                await context.read(libraryProvider).addToLibrary(widget.anime);
                showSnackBar(context, "Added to Library");
              }
              setState(() {
                isAdded = !isAdded;
              });
            },
            icon: Icon(isAdded ? Icons.favorite : Icons.favorite_border),
          ),
          if (!kIsWeb)
            Consumer(builder: (context, w, _) {
              final downloadedSeries =
                  w(downloadedSeriesProvider).downloadedSeries;
              bool downloadInclude = false;
              for (var i in downloadedSeries) {
                if (i.anime.title == widget.anime.title) {
                  downloadInclude = true;
                  break;
                }
              }
              return IconButton(
                  onPressed: () async {
                    if (downloadInclude) {
                      await showGeneralDialog(
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AlertDialog(
                            content: const Text(
                                'Are you sure you want to delete this series?'),
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
                                        .deleteDownloadSeries(widget.anime);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("delete"))
                            ],
                          );
                        },
                      );
                    } else {
                      await showGeneralDialog(
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AlertDialog(
                            content: const Text('Are you sure?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("cancel")),
                              TextButton(
                                  onPressed: () async {
                                    // await loading(
                                    //     context,
                                    //     context
                                    //         .read(downloadedSeriesProvider.)
                                    //         .downloadAll(widget.l));
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("add"))
                            ],
                          );
                        },
                      );
                    }
                  },
                  icon: Icon(downloadInclude ? Icons.done : Icons.download));
            })
        ],
      ),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: () async {
          await refreshOne(context, widget.anime);
        },
        child: FractionallySizedBox(
          heightFactor: 1,
          widthFactor: 1,
          child: OrientationBuilder(builder: (context, o) {
            return LayoutBuilder(builder: (context, constraints) {
              return Flex(
                direction:
                    o == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                children: [
                  Flexible(
                    flex: 1,
                    child: o == Orientation.portrait
                        ? thumbnailPro(widget, o, context)
                        : thumbnail(widget, o, context),
                  ),
                  Flexible(
                      flex: o == Orientation.landscape ? 2 : 1,
                      child: EpisodeList(
                        anime: widget.anime,
                        currentEpisodeId: -1,
                        navType: NavType.push,
                      ))
                ],
              );
            });
          }),
        ),
      )),
    );
  }
}

Widget thumbnailPro(widget, o, c) {
  return Flex(
    direction: o == Orientation.portrait ? Axis.horizontal : Axis.vertical,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            // vertical: 2,
          ),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: !kIsWeb
                ? CachedNetworkImage(
                    alignment: Alignment.center,
                    imageUrl: widget.anime.img as String,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    memCacheWidth: 200,
                    memCacheHeight: 300,
                  )
                : Image.network(
                    widget.anime.img,
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  )
            // HtmlElementView(
            //     viewType: "<img src = '${widget.anime.img}'></img>",
            //   )
            ,
          ),
        ),
      ),
      Flexible(
        flex: 1,
        child: SingleChildScrollView(
          // pu
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Title: ${widget.anime.title}",
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 10),
              Text("Total Episodes: ${widget.anime.episodes.length}"),
              const SizedBox(height: 10),
              Text("${widget.anime.synopsis}"),
              const SizedBox(height: 10),
              Text(
                  'Genre: ${widget.anime.genres.toString().replaceAll("[", "").replaceAll("]", "")}'),
              const SizedBox(height: 10),
              Text("Released: ${widget.anime.released}"),
              const SizedBox(height: 10),
              Text("Status: ${widget.anime.status}"),
              const SizedBox(height: 10),
              Text("Other Names: ${widget.anime.otherName}"),
            ],
          ),
        ),
      )
    ],
  );
}

Widget thumbnail(widget, o, c) {
  return CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: !kIsWeb
                ? CachedNetworkImage(
                    alignment: Alignment.center,
                    imageUrl: widget.anime.img as String,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    memCacheWidth: 200,
                    memCacheHeight: 300,
                  )
                : Image.network(
                    widget.anime.img,
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Title: ${widget.anime.title}",
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 10),
            Text("Total Episodes: ${widget.anime.episodes.length}"),
            const SizedBox(height: 10),
            Text("${widget.anime.synopsis}"),
            const SizedBox(height: 10),
            Text(
                'Genre: ${widget.anime.genres.toString().replaceAll("[", "").replaceAll("]", "")}'),
            const SizedBox(height: 10),
            Text("Released: ${widget.anime.released}"),
            const SizedBox(height: 10),
            Text("Status: ${widget.anime.status}"),
            const SizedBox(height: 10),
            Text("Other Names: ${widget.anime.otherName}"),
          ],
        ),
      )
    ],
  );
}
