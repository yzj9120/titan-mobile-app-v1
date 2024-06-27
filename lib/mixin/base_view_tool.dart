import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

mixin BaseViewTool {
  void showToast(String msg, {bool showLong = false}) {
    Fluttertoast.showToast(
      msg: msg,
      fontSize: 12..sp,
      gravity: ToastGravity.CENTER,
      toastLength: showLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 2,
    );
  }

  ///申请存本地相册权限
  Future<bool> checkAndRequestPermissions() async {
    if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (status.isDenied) {
        Map<Permission, PermissionStatus> statuses =
            await [Permission.photos].request();
        return statuses[Permission.photos]!.isGranted;
      } else {
        //_showSettingsDialog
        return false;
      }
    } else {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // if (androidInfo.version.sdkInt < 33) {
      //   if (await Permission.storage.request().isGranted) {
      //     return true;
      //   } else if (await Permission.storage.request().isPermanentlyDenied) {
      //     await openAppSettings();
      //   } else if (await Permission.audio.request().isDenied) {
      //     return false;
      //   }
      // } else {
      //   if (await Permission.photos.request().isGranted) {
      //     return true;
      //   } else if (await Permission.photos.request().isPermanentlyDenied) {
      //     await openAppSettings();
      //   } else if (await Permission.photos.request().isDenied) {
      //     return false;
      //   }
      // }
      if (androidInfo.version.sdkInt >= 33) {
        List<Permission> permissions = [Permission.videos, Permission.audio];
        Map<Permission, PermissionStatus> statuses =
            await permissions.request();
        bool allGranted = statuses.values.every((status) => status.isGranted);

        if (allGranted) {
          return true;
        } else {
          bool isDenied = statuses.values.any((status) => status.isDenied);
          if (isDenied) {
            statuses = await permissions.request();
            return statuses.values.every((status) => status.isGranted);
          } else {
            return await openAppSettings();
          }
        }
      } else {
        var storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) {
          return true;
        } else if (storageStatus.isPermanentlyDenied) {
          return await openAppSettings();
        } else {
          PermissionStatus status = await Permission.storage.request();
          if (status.isGranted) {
            return true;
          } else {
            return await openAppSettings();
          }
        }
      }
    }
  }
}
