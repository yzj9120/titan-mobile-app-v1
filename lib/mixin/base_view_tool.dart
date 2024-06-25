import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../themes/colors.dart';

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
}
