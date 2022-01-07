import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
part 'episode.g.dart';

@HiveType(typeId: 90)
enum EpisodeType {
  @HiveField(0)
  network,
  @HiveField(1)
  iframe,
  @HiveField(2)
  file,
}

@immutable
@HiveType(typeId: 1)
class Episode {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<Servers> servers;
  @HiveField(2)
  final EpisodeType type;
  @HiveField(3)
  final String? downloadId;

  const Episode({
    required this.id,
    required this.servers,
    this.type = EpisodeType.network,
    this.downloadId,
  });

  // Episode.fromJson(Map<String, dynamic> json) {
  //   id = json['id'];
  // }
  @override
  bool operator ==(Object other) {
    if (other.runtimeType == Episode) {
      if ((other as Episode).id == id) {
        return true;
      }
    }
    return false;
  }

  Episode copyWith({
    String? id,
    List<Servers>? servers,
    EpisodeType? type,
    String? downloadId,
  }) {
    return Episode(
      id: id ?? this.id,
      servers: servers ?? this.servers,
      type: type ?? this.type,
      downloadId: downloadId ?? this.downloadId,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['downloadId'] = downloadId;
    final Map<String, dynamic> d2 = {};
    for (var element in servers) {
      d2[element.name] = element.iframe;
    }
    data['servers'] = d2;
    return data;
  }
}

@immutable
@HiveType(typeId: 2)
class Servers {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String iframe;

  const Servers({
    required this.name,
    required this.iframe,
  });

  // Servers.fromJson(Map<String, dynamic> json) {
  //   name = json['name'];
  //   iframe = json['iframe'];
  // }

  Servers copyWith({
    String? name,
    String? iframe,
  }) {
    return Servers(
      name: name ?? this.name,
      iframe: iframe ?? this.iframe,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['iframe'] = iframe;
    return data;
  }
}
