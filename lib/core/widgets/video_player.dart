import 'dart:io';

import 'package:animely/core/constants/constants.dart';
import 'package:animely/core/models/anime.dart';
import 'package:animely/core/models/episode.dart';
import 'package:animely/core/widgets/episode_list.dart';
import 'package:animely/core/widgets/video_player_pannel.dart';
import 'package:animely/navigation/test_screen.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:fijkplayer_skin/schema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class PlayerShowConfig implements ShowConfigAbs {
  @override
  bool drawerBtn = true;
  @override
  bool nextBtn = false;
  @override
  bool speedBtn = true;
  @override
  bool topBar = true;
  @override
  bool lockBtn = true;
  @override
  bool autoNext = false;
  @override
  bool bottomPro = false;
  @override
  bool stateAuto = true;
  @override
  bool isAutoPlay = true;
}

class VideoPlayer extends StatefulWidget {
  final Episode currentEpisode;
  final Anime anime;
  final int episodeId;
  const VideoPlayer({
    Key? key,
    required this.currentEpisode,
    required this.anime,
    required this.episodeId,
  }) : super(key: key);
  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  FlickManager? _flickManager;
  VideoPlayerController? _videoPlayerController;
  FijkPlayer? player;
  ShowConfigAbs? vCfg;

  int _curTabIdx = 0;
  int cur = 0;
  int _curActiveIdx = 0;
  bool isFirst = false;
  Map<String, List<Map<String, dynamic>>> videoList = {};

  VideoSourceFormat? _videoSourceTabs;
  void init() {
    print(widget.currentEpisode.toJson());
    switch (widget.currentEpisode.type) {
      case EpisodeType.file:
        {
          _videoPlayerController =
              VideoPlayerController.file(File(getLink("file")));
          _flickManager = FlickManager(
            videoPlayerController: _videoPlayerController!,
          );

          break;
        }
      case EpisodeType.network:
        {
          player = FijkPlayer();
          vCfg = PlayerShowConfig();
          player!.addListener(_playerCallBack);
          final link = getLink("stream_link");
          final reso = getResolutions(link);

          videoList = {
            "video": [
              {
                "name": widget.anime.title,
                "list": [
                  {"url": link, "name": "auto"},
                  ...reso.keys.map((e) {
                    return {"url": reso[e], "name": e};
                  })
                ]
              },
            ]
          };
          _videoSourceTabs = VideoSourceFormat.fromJson(videoList);
          speed = 1.0;
          break;
        }
      case EpisodeType.iframe:
        {
          // String url = getLink('main');
          // html.window.open("https://" + url, '_blank');
          break;
        }
    }
  }

  void onChangeVideo(int curTabIdx, int curActiveIdx) {
    setState(() {
      cur = player!.currentPos.inMilliseconds;
      if (cur > 5000) {
        isFirst = true;
      }
      _curTabIdx = curTabIdx;
      _curActiveIdx = curActiveIdx;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  void delete() async {
    if (player != null) {
      await player!.stop();
      player!.removeListener(_playerCallBack);
      player!.dispose();
    }
    if (_flickManager != null) {
      _flickManager!.dispose();
      // _flickManager!.flickVideoManager.
    }
  }

  @override
  void dispose() {
    delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anime.title),
      ),
      body: LayoutBuilder(builder: (context, c) {
        return SafeArea(
          child: SizedBox(
            width: c.maxWidth,
            height: c.maxHeight,
            child: OrientationBuilder(builder: (context, o) {
              return Flex(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                direction:
                    o == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                children: [
                  if (!kIsWeb)
                    Flexible(
                      flex: o == Orientation.portrait ? 0 : 2,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: widget.currentEpisode.type != EpisodeType.file
                            ? FijkView(
                                color: Colors.black,
                                fit: FijkFit.cover,
                                player: player!,
                                panelBuilder: _pannelBuilder,
                              )
                            : FlickVideoPlayer(
                                preferredDeviceOrientation: const [
                                  DeviceOrientation.portraitUp,
                                  DeviceOrientation.landscapeLeft,
                                  DeviceOrientation.landscapeRight,
                                ],
                                preferredDeviceOrientationFullscreen: const [
                                  // DeviceOrientation.portraitUp,
                                  DeviceOrientation.landscapeLeft,
                                  DeviceOrientation.landscapeRight,
                                ],
                                flickManager: _flickManager!,
                                flickVideoWithControls:
                                    const CustomVideoWithControls(
                                  videoFit: BoxFit.contain,
                                  controls: FlickPortraitControls(),
                                ),
                              ),
                      ),
                    ),
                  // const SizedBox(
                  //   width: 10,
                  // ),
                  Expanded(
                    flex: 1,
                    child: EpisodeList(
                      anime: widget.anime,
                      currentEpisodeId: widget.episodeId,
                      navType: NavType.replace,
                    ),
                  )
                ],
              );
            }),
          ),
        );
      }),
    );
  }

  String getLink(String type) {
    String link = '';
    for (var i in widget.currentEpisode.servers) {
      if (i.name == type) {
        link = i.iframe;
        break;
      }
    }
    return link;
  }

  Map<String, String> getResolutions(String link) {
    Map<String, String> reso = {};

    List<String> a = link.split(".");
    if (a.last == "m3u8") {
      final b1 = a[a.length - 2] == "360";
      final b2 = a[a.length - 2] == "480";
      final b3 = a[a.length - 2] == "720";
      final b4 = a[a.length - 2] == "1080";

      if (!(b1 || b2 || b3 || b4)) {
        reso['360p'] = link.replaceFirst("m3u8", "360.m3u8");
        reso['480p'] = link.replaceFirst("m3u8", "480.m3u8");
        reso['720p'] = link.replaceFirst("m3u8", "720.m3u8");
        reso['1080p'] = link.replaceFirst("m3u8", "1080.m3u8");
      } else {
        String t = "360";
        if (b2) {
          t = "480";
        } else if (b3) {
          t = "720";
        } else if (b4) {
          t = "1080";
        }
        reso['360p'] = link.replaceFirst("$t.m3u8", "360.m3u8");
        reso['480p'] = link.replaceFirst("$t.m3u8", "480.m3u8");
        reso['720p'] = link.replaceFirst("$t.m3u8", "720.m3u8");
        reso['1080p'] = link.replaceFirst("$t.m3u8", "1080.m3u8");
      }
    }
    return reso;
  }

  Widget _pannelBuilder(
    FijkPlayer player,
    FijkData data,
    BuildContext context,
    Size viewSize,
    Rect texturePos,
  ) {
    SystemChrome.setPreferredOrientations([
      if (!player.value.fullScreen) DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Wakelock.enabled.then((value) {
      if (!value) {
        Wakelock.enable();
      }
    });
    Constant.headers.forEach((key, value) {
      player.setOption(FijkOption.formatCategory, "headers", "$key: $value");
    });

    return CustomFijkPanel(
      player: player,
      pageContent: context,
      viewSize: viewSize,
      texturePos: texturePos,
      playerTitle: player.value.fullScreen ? widget.anime.title : "",
      curTabIdx: _curTabIdx,
      curActiveIdx: _curActiveIdx,
      showConfig: vCfg!,
      videoFormat: _videoSourceTabs,
      onChangeVideo: onChangeVideo,
    );
  }

  void _playerCallBack() {
    SystemChrome.setPreferredOrientations([
      if (!player!.value.fullScreen) DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Wakelock.enabled.then((value) {
      if (!value) {
        Wakelock.enable();
      }
    });
    if (player!.value.videoRenderStart && isFirst) {
      if (cur - 5000 > 5000) {
        player!.seekTo(cur - 6000);
      }
      isFirst = false;
    }
    // setState(() {});
  }
}

/// Default portrait controls.
class FlickPortraitControls extends StatelessWidget {
  const FlickPortraitControls({
    Key? key,
    this.iconSize = 20,
    this.fontSize = 12,
  }) : super(key: key);
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: FlickAutoHideChild(
          child: Container(
            color: Colors.black.withOpacity(0.15),
          ),
        )),
        const Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: FlickVideoBuffer(
                  child: FlickAutoHideChild(
                    showIfVideoNotInitialized: false,
                    child: FlickPlayToggle(
                      size: 60,
                      color: Colors.white,
                      // padding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      backgroundColor: Colors.white,
                      bufferedColor: Colors.black.withOpacity(0.7),
                      playedColor: Colors.blue,
                      handleColor: Colors.blue,
                      handleRadius: 7,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlickPlayToggle(
                        size: iconSize,
                      ),
                      SizedBox(
                        width: iconSize / 2,
                      ),
                      FlickSoundToggle(
                        size: iconSize,
                      ),
                      SizedBox(
                        width: iconSize / 2,
                      ),
                      Row(
                        children: <Widget>[
                          FlickCurrentPosition(
                            fontSize: fontSize,
                          ),
                          FlickAutoHideChild(
                            child: Text(
                              ' / ',
                              style: TextStyle(
                                  color: Colors.white, fontSize: fontSize),
                            ),
                          ),
                          FlickTotalDuration(
                            fontSize: fontSize,
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            FlickControlManager controlManager =
                                Provider.of<FlickControlManager>(context,
                                    listen: false);
                            if (!controlManager.isFullscreen) {
                              controlManager.toggleFullscreen();
                            }
                            FlutterAndroidPip.enterPictureInPictureMode();
                          },
                          icon: const Icon(Icons.picture_in_picture_alt)),
                      SizedBox(
                        width: iconSize / 2,
                      ),
                      FlickFullScreenToggle(
                        size: iconSize,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Default Video with Controls.
///
/// Returns a Stack with the following arrangement.
///    * [FlickVideoPlayer]
///    * Stack (Wrapped with [Positioned.fill()])
///      * Video Player loading fallback (conditionally rendered if player is not initialized).
///      * Video player error fallback (conditionally rendered if error in initializing the player).
///      * Controls.
class CustomVideoWithControls extends StatefulWidget {
  const CustomVideoWithControls({
    Key? key,
    this.controls,
    this.videoFit = BoxFit.cover,
    this.playerLoadingFallback = const Center(
      child: CircularProgressIndicator(),
    ),
    this.playerErrorFallback = const Center(
      child: Icon(
        Icons.error,
        color: Colors.white,
      ),
    ),
    this.backgroundColor = Colors.black,
    this.iconThemeData = const IconThemeData(
      color: Colors.white,
      size: 20,
    ),
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    this.aspectRatioWhenLoading = 16 / 9,
    this.willVideoPlayerControllerChange = true,
  }) : super(key: key);

  /// Create custom controls or use any of these [FlickPortraitControls], [FlickLandscapeControls]
  final Widget? controls;

  /// Conditionally rendered if player is not initialized.
  final Widget playerLoadingFallback;

  /// Conditionally rendered if player is has errors.
  final Widget playerErrorFallback;

  /// Property passed to [FlickVideoPlayer]
  final BoxFit videoFit;
  final Color backgroundColor;

  /// Used in [DefaultTextStyle]
  ///
  /// Use this property if you require to override the text style provided by the default Flick widgets.
  ///
  /// If any text style property is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final TextStyle textStyle;

  /// Used in [IconTheme]
  ///
  /// Use this property if you require to override the icon style provided by the default Flick widgets.
  ///
  /// If any icon style is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final IconThemeData iconThemeData;

  /// If [FlickPlayer] has unbounded constraints this aspectRatio is used to take the size on the screen.
  ///
  /// Once the video is initialized, video determines size taken.
  final double aspectRatioWhenLoading;

  /// If false videoPlayerController will not be updated.
  final bool willVideoPlayerControllerChange;

  get videoPlayerController => null;

  @override
  _CustomVideoWithControlsState createState() =>
      _CustomVideoWithControlsState();
}

class _CustomVideoWithControlsState extends State<CustomVideoWithControls> {
  VideoPlayerController? _videoPlayerController;

  @override
  void didChangeDependencies() {
    VideoPlayerController? newController =
        Provider.of<FlickVideoManager>(context).videoPlayerController;
    if ((widget.willVideoPlayerControllerChange &&
            _videoPlayerController != newController) ||
        _videoPlayerController == null) {
      _videoPlayerController = newController;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return IconTheme(
        data: widget.iconThemeData,
        child: Container(
          color: widget.backgroundColor,
          child: DefaultTextStyle(
            style: widget.textStyle,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    // left: 0,
                    // right: 0,
                    top: 0, bottom: 0,
                    child: SizedBox(
                      width: c.maxWidth,
                      height: c.maxHeight,
                      child: Center(
                        child: FlickNativeVideoPlayer(
                          videoPlayerController: _videoPlayerController,
                          fit: widget.videoFit,
                          aspectRatioWhenLoading: widget.aspectRatioWhenLoading,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Stack(
                      children: <Widget>[
                        if (_videoPlayerController?.value.hasError == false &&
                            _videoPlayerController?.value.isInitialized ==
                                false)
                          widget.playerLoadingFallback,
                        if (_videoPlayerController?.value.hasError == true)
                          widget.playerErrorFallback,
                        widget.controls ?? const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
