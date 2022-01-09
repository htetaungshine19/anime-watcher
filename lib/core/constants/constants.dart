import 'package:flutter/material.dart';

class Constant {
  static const String url = "https://www1.gogoanime.cm/";

  static const String downloadDbName = "downtest1";
  static const String currentQue = "currentQue224";
  static const String downlaodqueDbName = "downtest134";
  static const String libraryDbName = "librarytest1";
  static const String searchDbName = "searchDb";
  static const String filterApiKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjU2NCIsIm5iZiI6MTYzNTA4OTc3NiwiZXhwIjoxNjM3NjgxNzc2LCJpYXQiOjE2MzUwODk3NzZ9.G1DuaZMu7U_X2dMe1PWzX2-EvXrQTajKTpsZrMaTWjw";

  static String externalStorageDir = "";
  static String resolution = "480";

  static const Map<String, String> headers = {
    'Referer': 'https://gogoplay1.com/',
  };
  static GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
}
