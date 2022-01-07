import 'package:animely/core/api/api.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/core/providers/provider.dart';
import 'package:animely/core/utils/clean_string.dart';
import 'package:animely/core/utils/copytoclip.dart';
import 'package:animely/core/utils/loading.dart';
import 'package:animely/core/utils/refresh.dart';
import 'package:animely/core/utils/show_snackbar.dart';
import 'package:animely/core/widgets/anime_detail_screen.dart';
import 'package:animely/core/widgets/anime_grid.dart';
import 'package:animely/library/presentation/library_provider.dart';
import 'package:animely/search/data/network/network.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimeGridItem extends StatefulWidget {
  final Anime anime;
  final bool showLibraryStatus;
  final ScreenToScroll screenType;
  final GestureTapCallback? onTap;
  const AnimeGridItem({
    Key? key,
    required this.anime,
    required this.showLibraryStatus,
    this.onTap,
    required this.screenType,
  }) : super(key: key);

  @override
  State<AnimeGridItem> createState() => _AnimeGridItemState();
}

class _AnimeGridItemState extends State<AnimeGridItem> {
  // @override
  // void initState() {
  //   if (widget.screenType == ScreenToScroll.recent) {
  //     refreshOneLibrary(context, widget.anime);
  //   }
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        await copyToClipboard(context, widget.anime.title.split('\n')[0]);
      },
      onTap: widget.onTap ??
          () async {
            final isItemInside =
                context.read(libraryProvider).isItemInside(widget.anime);

            if (isItemInside) {
              final libraryAnime =
                  context.read(libraryProvider).getItemInside(widget.anime);
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return ShowAnimeDetail(anime: libraryAnime);
                },
              ));
            } else {
              String id = widget.anime.id;
              if (id.isEmpty) {
                final l = await loading(
                    context, search(cleanString(widget.anime.title), 1));
                if (l.state == NetworkState.error ||
                    (l.data as List<Anime>).isEmpty) {
                  showSnackBar(context, "can't find the series");
                  return;
                } else if ((l.data as List<Anime>).length == 1) {
                  id = (l.data as List<Anime>).first.id;
                } else {
                  bool cache = true;
                  await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return LayoutBuilder(builder: (context, me) {
                        return AnimeGrid(
                          screenType: ScreenToScroll.filter,
                          isOffline: false,
                          fetch: (page) async {
                            if (cache) {
                              cache = false;
                              return l;
                            } else {
                              return await search(
                                  cleanString(widget.anime.title), page);
                            }
                          },
                        );
                      });
                    },
                  );
                  return;
                }
              }
              final pushAnime = await loading(context, animeHandler(id));
              if (pushAnime.state != NetworkState.error) {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return ShowAnimeDetail(anime: pushAnime.data as Anime);
                  },
                ));
              }
            }
          },
      child: GridTile(
        header: Consumer(
          builder: (context, w, child) {
            final isItemInside = w(libraryProvider).isItemInside(widget.anime);
            final noti = w(libraryProvider).noti;

            if (widget.showLibraryStatus) {
              return isItemInside
                  ? Align(
                      child: ElevatedButton.icon(
                        label: const Text("In Library"),
                        icon: const Icon(Icons.favorite),
                        onPressed: () async {
                          context
                              .read(libraryProvider)
                              .removeFromLibrary(widget.anime);
                        },
                      ),
                      alignment: Alignment.topLeft,
                    )
                  : const SizedBox();
            }
            if (noti.keys.contains(widget.anime.id)) {
              return Align(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    noti[widget.anime.id]!,
                  ),
                ),
                alignment: Alignment.topLeft,
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Consumer(builder: (context, w, _) {
                final isItemInside =
                    w(libraryProvider).isItemInside(widget.anime);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: !kIsWeb
                      ? CachedNetworkImage(
                          useOldImageOnUrlChange: true,
                          colorBlendMode: BlendMode.xor,
                          color: !widget.showLibraryStatus
                              ? null
                              : isItemInside
                                  ? Colors.black.withOpacity(0.6)
                                  : Colors.transparent,
                          imageUrl: widget.anime.img,
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
                );
              }),
            ),
            Text(
              widget.anime.title.split('\n')[0],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (widget.anime.title.split("\n").length > 1)
              Text(
                widget.anime.title.split("\n")[1],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}
