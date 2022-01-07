import 'package:animely/search/data/database/repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchHistory extends StateNotifier<List<String>> {
  SearchHistory(List<String> l) : super(l);

  Future<void> addToHistory(String s) async {
    if (!state.contains(s)) {
      if (state.length > 30) {
        await SearchRepo.replaceSearchHistory(s);
        final List<String> t = state;
        t.removeAt(0);
        t.add(s);
        state = t;
      } else {
        await SearchRepo.addSearchHistory(s);
        final List<String> t = state;
        t.add(s);
        state = t;
      }
    } else {
      final List<String> t = state;
      if (t.contains(s)) {
        t.remove(s);
      }
      t.add(s);
      await SearchRepo.deleteSearchHistory(s);
      await SearchRepo.addSearchHistory(s);

      state = t;
    }
  }

  Future<void> removeHistory(String s) async {
    if (state.contains(s)) {
      final List<String> t = state;
      t.remove(s);
      await SearchRepo.deleteSearchHistory(s);
      state = t;
    }
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistory, List<String>>((_) {
  throw UnimplementedError();
});
