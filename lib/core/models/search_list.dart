

import 'package:animely/core/models/anime.dart';

class SearchLists {
  List<Anime> search = [];

  SearchLists({required this.search});

  SearchLists.fromJson(Map<String, dynamic> json) {
    if (json['search'] != null) {
      search = [];
      json['search'].forEach((v) {
        search.add(Anime.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['search'] = search.map((v) => v.toJson()).toList();

    return data;
  }
}
