
import 'package:animely/search/data/database/usecases/add_search.dart';
import 'package:animely/search/data/database/usecases/delete_search.dart';
import 'package:animely/search/data/database/usecases/get_search.dart';
import 'package:animely/search/data/database/usecases/replace_search.dart';

class SearchRepo {
  static Future<void> addSearchHistory(String search) async {
    return addSearch(search);
  }

  static Future deleteSearchHistory(String search) async {
    return removeS(search);
  }

  static Future replaceSearchHistory(String search) async {
    return replace(search);
  }

  static Future<List<String>> getSearchHistory() async {
    return getSearch();
  }
}
