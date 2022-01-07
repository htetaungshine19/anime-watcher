import 'package:flutter/cupertino.dart';

class Filter with ChangeNotifier {
  String? _seasons;
  String get seasons {
    if (_seasons != null) {
      return _seasons!;
    } else {
      return "";
    }
  }

  set seasons(String y) {
    _seasons = y;
    notifyListeners();
  }

  String? _keyword;
  String get keyword {
    if (_keyword != null) {
      return _keyword!;
    } else {
      return "";
    }
  }

  set keyword(String y) {
    _keyword = y;
    notifyListeners();
  }

  String _genre = "action";
  String get genre {
    return _genre;
  }

  set genre(String y) {
    _genre = y;
    notifyListeners();
  }

  String? _year;
  String get year {
    if (_year != null) {
      return _year!;
    } else {
      return "";
    }
  }

  set year(String y) {
    _year = y;
    notifyListeners();
  }

  String? _status;
  String get status {
    if (_status != null) {
      return _status!;
    } else {
      return "";
    }
  }

  set status(String y) {
    _status = y;
    notifyListeners();
  }

  String? _format;
  String get format {
    if (_format != null) {
      return _format!;
    } else {
      return "";
    }
  }

  set format(String y) {
    _format = y;
    notifyListeners();
  }

  void reset() {
    _seasons = null;
    _status = null;
    _year = null;
    _format = null;
    _keyword = null;
    notifyListeners();
  }
}
