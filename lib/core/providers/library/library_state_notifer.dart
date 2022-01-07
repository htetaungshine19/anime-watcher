import 'package:animely/core/models/anime.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LibraryState {
  idle,
  refreshing,
}

@immutable
class LibraryWrapper {
  final Map<String, Anime> addedSeries;
  final LibraryState state;

  const LibraryWrapper({
    this.addedSeries = const {},
    this.state = LibraryState.idle,
  });

  LibraryWrapper copyWith({
    Map<String, Anime>? addedSeries,
    LibraryState? state,
  }) {
    return LibraryWrapper(
      addedSeries: addedSeries ?? this.addedSeries,
      state: state ?? this.state,
    );
  }
}

class LibraryStateNotifier extends StateNotifier<LibraryWrapper> {
  LibraryStateNotifier() : super(const LibraryWrapper()) {
    init();
  }
  void init() async {}
}
