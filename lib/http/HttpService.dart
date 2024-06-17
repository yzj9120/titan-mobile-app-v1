import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/appConfig.dart';
import '../providers/version_provider.dart';
import 'HttpUtil.dart';

class HttpService {
  final HttpUtil _networkUtil = HttpUtil();

  Future<void> checkAppVersion(
      BuildContext context, String lang, String platf) async {
    try {
      final String url = '${AppConfig.webServerURL}/api/v2/app_version';
      final headers = {'Lang': lang, 'platform': platf};
      final data = await _networkUtil.getRequest(url, headers);
      debugPrint('_getVersion：${data.toString()}');

      if (data['code'] == 0) {
        Provider.of<VersionProvider>(context, listen: false).setVersion(
          data['data']['version'],
          data['data']['description'],
          data['data']['url'],
          data['data']['cid'],
        );
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch app version. API response code: ${data['code']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while checking app version: $e');
      }
    }
  }

  Future<String> discord() async {
    try {
      final String url = '${AppConfig.webServerURL}/api/v1/url/discord';
      final data = await _networkUtil.getRequest(url, null);

      if (data['code'] == 0) {
        return data['data'];
      } else {
        return AppConfig.discordURL;
      }
    } catch (e) {
      return AppConfig.discordURL;
    }
  }

  Future<void> banners(String lang) async {
    try {
      final String url = '${AppConfig.webServerURL}/api/v1/users/ads/banners';
      final headers = {'Lang': lang, 'platform': "2"};
      final data = await _networkUtil.getRequest(url, headers);
      debugPrint('banners：${data.toString()}');

      if (data['code'] == 0) {
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch app version. API response code: ${data['code']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while checking app version: $e');
      }
    }
  }

  Future<void> notice(BuildContext context, String lang, String platf) async {
    try {
      final String url = '${AppConfig.webServerURL}/api/v1/users/ads/notice';
      final headers = {'Lang': lang, 'platform': platf};
      final data = await _networkUtil.getRequest(url, headers);
      debugPrint('banners：${data.toString()}');

      if (data['code'] == 0) {
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch app version. API response code: ${data['code']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while checking app version: $e');
      }
    }
  }
}
