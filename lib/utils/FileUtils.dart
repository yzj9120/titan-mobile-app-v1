import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titan_app/config/appConfig.dart';
import 'package:toml/toml.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
class FileUtils{

  static Future<void> init() async {
    var directory = await getApplicationDocumentsDirectory();
    var repoPath = path.join(directory.path, "titanl2");
    var repoDirectory = Directory(repoPath);
    if (!await repoDirectory.exists()) {
      await repoDirectory.create();
    }
  }
}
