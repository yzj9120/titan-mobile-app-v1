import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class VersionProvider extends ChangeNotifier {
  String _remoteVersion = '1.0.0';
  String _currentVersion = '1.0.0';
  String _desc = '';
  String _url = '';
  String get remoteVersion => _remoteVersion;
  String get currentVersion => _currentVersion;
  String get url => _url;
  String get desc => _desc;
  bool get isUpgradeAble => _compare(_remoteVersion, _currentVersion) > 0;

  VersionProvider() {
    _loadVersionInfo();
  }

  static int _compare(String v1, v2) {
    return Version.parse(v1).compareTo(Version.parse(v2));
  }

  Future<void> _loadVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    _remoteVersion = _currentVersion;

    notifyListeners();
  }

  setVersion(String val, String description, String urlVal) async {
    if (val.startsWith('v') || val.startsWith('V')) {
      val = val.substring(1);
    }

    if (_remoteVersion == val && description == _desc && _url == urlVal) {
      return;
    }

    _remoteVersion = val;
    _desc = description;
    _url = urlVal;

    notifyListeners();
  }
}
