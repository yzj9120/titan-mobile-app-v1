import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:titan_app/config/appConfig.dart';
import 'package:titan_app/ext/extension_num.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bridge/bridge_mgr.dart';
import '../../config/constant.dart';
import '../../http/HttpService.dart';
import '../../l10n/generated/l10n.dart';
import '../../providers/localization_provider.dart';
import '../../themes/colors.dart';
import '../../utils/shared_preferences.dart';
import '../../widgets/common_text_widget.dart';
import 'feedback_list_page.dart';

class ProblemFeedbackPage extends StatefulWidget {
  const ProblemFeedbackPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProblemFeedbackState();
  }
}

class _ProblemFeedbackState extends State<ProblemFeedbackPage> {
  String address = "";
  int feedback_type = 1;
  final TextEditingController _telegramController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Picture> picList = [];

  @override
  void initState() {
    address = TTSharedPreferences.getString(Constant.userAddress) ?? "";
    picList.add(Picture(url: "", type: -1));
    super.initState();
  }

  @override
  void dispose() {
    _telegramController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  InputBorder inputBorder() {
    return const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.transparent));
  }

  var textStyle = TextStyle(
      fontSize: 12, color: AppDarkColors.tabBarNormalColor.withOpacity(0.6));

  Widget box(margin, child, {Color? color, double? radius = 10}) => Container(
        width: double.infinity,
        height: double.infinity,
        margin: margin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color, // Hex color value
          borderRadius: BorderRadius.all(Radius.circular(radius!)),
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: CommonTextWidget(
            S.of(context).submitBugs,
            fontSize: FontSize.large,
          ),
          iconTheme: const IconThemeData(color: AppDarkColors.iconColor),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedbackListPage()),
                );
              },
              child: SizedBox(
                width: 95.w,
                height: 33.h,
                child: box(
                    EdgeInsets.only(right: 15.w),
                    Text(
                      S.of(context).history,
                      style:
                          textStyle.copyWith(color: AppDarkColors.themeColor),
                    ),
                    color: const Color(0xFF171717)),
              ),
            )
          ],
          backgroundColor: AppDarkColors.backgroundColor,
        ),
        body: Container(
          margin: EdgeInsets.all(15.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Text(
                      "${S.of(context).nodeId}:",
                      style: textStyle,
                    ),
                    Text(
                      BridgeMgr().daemonBridge.daemonCfgs.id().truncate(),
                      style: textStyle.copyWith(
                          fontSize: 14, color: AppDarkColors.tabBarNormalColor),
                    )
                  ],
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Text(
                      "${S.of(context).email}:",
                      style: textStyle,
                    ),
                    Text(
                      address,
                      style: textStyle.copyWith(
                          fontSize: 14, color: AppDarkColors.tabBarNormalColor),
                    )
                  ],
                ),
                SizedBox(height: 30.h),
                Text(
                  S.of(context).setting_telegram,
                  style: textStyle,
                ),
                SizedBox(height: 20.h),
                Container(
                  width: 340.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF181818), // Hex color value
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    controller: _telegramController,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 10.w, right: 10.w),
                      focusedBorder: inputBorder(),
                      disabledBorder: inputBorder(),
                      errorBorder: inputBorder(),
                      focusedErrorBorder: inputBorder(),
                      enabledBorder: inputBorder(),
                      // border: inputBorder(),
                      hintText: S.of(context).telegramDsc,
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12), // Text color
                  ),
                ),
                SizedBox(height: 30.h),
                Text(
                  S.of(context).yourQuestion,
                  style: textStyle,
                ),
                SizedBox(height: 20.h),
                Container(
                  width: 340.w,
                  height: 180.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF181818), // Hex color value
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 10.w, right: 10.w),
                      focusedBorder: inputBorder(),
                      disabledBorder: inputBorder(),
                      errorBorder: inputBorder(),
                      focusedErrorBorder: inputBorder(),
                      enabledBorder: inputBorder(),
                      // border: inputBorder(),
                      hintText: S.of(context).questionDsc,
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12), // Text color
                  ),
                ),
                SizedBox(height: 20.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: picList.length,
                  // 项目总数
                  itemBuilder: (context, index) {
                    var bean = picList[index];
                    return InkWell(
                      onTap: () {
                        onSelectPicture();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.center,
                        child: bean.type == -1
                            ? const Icon(
                                Icons.add,
                                color: AppDarkColors.themeColor,
                              )
                            : CachedNetworkImage(
                                imageUrl: 'https://via.placeholder.com/400x200',
                                // Replace with your image URL
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () {
                    _openDialog();
                  },
                  child: Container(
                    width: 335,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF52FF38), // Background color
                      borderRadius: BorderRadius.all(
                          Radius.circular(85)), // Border radius
                    ),
                    child: Text(
                      S.of(context).submit,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  var feedbackTypeList = ['意见', '咨询', '异常', '其他'];

  void _toast(msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  void _openDialog() {
    // if (_telegramController.text.trim().isEmpty) {
    //
    //   Fluttertoast.cancel();
    //   Fluttertoast.showToast(
    //     msg: S.of(context).telegramDsc,
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //   );
    //   return;
    // }
    // if (_contentController.text.trim().isEmpty) {
    //   Fluttertoast.cancel();
    //   Fluttertoast.showToast(
    //     msg: S.of(context).questionDsc,
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //   );
    //   return;
    // }
    // if (picList.isEmpty) {
    //   Fluttertoast.cancel();
    //   Fluttertoast.showToast(
    //     msg: S.of(context).pleasePicture,
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //   );
    //   return;
    // }

    _showModalBottomSheet(context);
  }

  //feedback_type1:意见 2:咨询 3:异常 4:其他, platform 1macos 2windows 3android 4ios
  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      // backgroundColor: Color(0x181818FF),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
      ),
      builder: (BuildContext context) {
        int selectindex = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 260.h,
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        S.of(context).feedbackDes,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 3.5,
                      ),
                      itemCount: feedbackTypeList.length,
                      // 项目总数
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectindex = index;
                            });
                          },
                          child: box(
                              const EdgeInsets.all(0),
                              Text(
                                feedbackTypeList[index],
                                style: TextStyle(
                                    color: selectindex == index
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              color: selectindex == index
                                  ? const Color(0xFF52FF38)
                                  : Colors.white10,
                              radius: 40.0),
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      feedback_type = selectindex + 1;
                      Navigator.of(context).pop();
                      onSubmit();
                    },
                    child: Container(
                      width: 335,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF52FF38), // Background color
                        borderRadius: BorderRadius.all(
                            Radius.circular(85)), // Border radius
                      ),
                      child: Text(
                        S.of(context).submit,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _checkPermissions() async {
    // Check camera permission
    // var cameraStatus = await Permission.camera.status;
    // if (!cameraStatus.isGranted) {
    //   await Permission.camera.request();
    // }
    //
    // // Check gallery permission
    // var galleryStatus = await Permission.photos.status;
    // if (!galleryStatus.isGranted) {
    //   await Permission.photos.request();
    // }
    //
    // if (cameraStatus.isGranted && galleryStatus.isGranted) {
    //   _pickImage(ImageSource.gallery);
    // } else {
    //   _toast('Permissions not granted!');
    // }

   var status = await Permission.manageExternalStorage.status;

   if(status!= PermissionStatus.granted){
     await Permission.manageExternalStorage.request();
   }else{
     _pickImage(ImageSource.gallery);
   }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    var _image = File(pickedFile!.path);
    var res = await HttpService().uploadImage(_image);

    print("=========xx==============$res");

  }

  void onSelectPicture() {
    _checkPermissions();
  }

  void onSubmit() {}
}

class Picture {
  final String url;
  final int type;

  Picture({
    required this.url,
    required this.type,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      url: json['url'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
    };
  }
}
