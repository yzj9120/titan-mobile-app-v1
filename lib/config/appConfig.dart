import 'package:flutter/services.dart';
import 'package:toml/toml.dart';

class AppConfig {
  static late Map<String, dynamic> _tomlConfig;

  static Future<void> load() async {
    _tomlConfig = await loadTomlConfig('assets/configs/config.toml');
  }

  static Future<Map<String, dynamic>> loadTomlConfig(String path) async {
    final tomlString = await rootBundle.loadString(path);
    final tomlMap = TomlDocument.parse(tomlString).toMap();
    return tomlMap;
  }

  static dynamic get webServerURL => _tomlConfig['Network']['WebServerURL'];
  static dynamic get locatorURL => _tomlConfig['Network']['LocatorURL'];
  static dynamic get nodeInfoURL => _tomlConfig['Network']['NodeInfoURL'];
  static dynamic get telegeramURL => _tomlConfig['Network']['TelegeramURL'];
  static dynamic get twitterURL => _tomlConfig['Network']['TwitterURL'];
  static dynamic get bindingHelpURL => _tomlConfig['Network']['BindingHelpURL'];
}
