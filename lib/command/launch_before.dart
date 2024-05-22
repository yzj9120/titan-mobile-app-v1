import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:titan_app/utils/FileUtils.dart';

import '../bridge/bridge_mgr.dart';
import '../config/appConfig.dart';
import 'package:path/path.dart' as path;

typedef ExecutePowerShellFunc = Void Function(Pointer<Utf8> command);
typedef ExecutePowerShell = void Function(Pointer<Utf8> command);

class LaunchBeforeCommand {
  ///sdk的初始化
  static Future<void> setUp() async {
    await FileUtils.init();
    await AppConfig.load();
    await BridgeMgr.init();
  }
}
