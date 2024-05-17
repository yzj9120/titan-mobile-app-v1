import 'dart:io';
import 'package:toml/toml.dart';

class ConfigLoader {
  final String filePath;
  late Map<String, dynamic> _config;

  ConfigLoader(this.filePath);

  Map<String, dynamic> loadConfig() {
    if (_config != null) {
      return _config;
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Config file not found: $filePath');
    }

    final content = file.readAsStringSync();
    _config = TomlDocument.parse(content).toMap();
    return _config;
  }

  dynamic getValue(String key) {
    final config = loadConfig();
    return config[key];
  }

  String get host {
    final config = loadConfig();
    final databaseConfig = config['database'];
    return databaseConfig != null ? databaseConfig['host'] : null;
  }

  int get port {
    final config = loadConfig();
    final databaseConfig = config['database'];
    return databaseConfig != null ? databaseConfig['port'] : null;
  }
}
