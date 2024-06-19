import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class AdsProvider extends ChangeNotifier {
  List<dynamic> _banners = [];

  List<dynamic> get banners => _banners;

  List<dynamic> _notices = [];

  List<dynamic> get notices => _notices;

  setBanners(List<dynamic> list) {
    _banners = list;
    notifyListeners();
  }

  setNotices(List<dynamic> list) {
    _notices = list;
    notifyListeners();
  }
}
