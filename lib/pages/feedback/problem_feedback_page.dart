import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:titan_app/config/appConfig.dart';
import 'package:titan_app/ext/extension_num.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bridge/bridge_mgr.dart';
import '../../http/HttpService.dart';
import '../../l10n/generated/l10n.dart';
import '../../providers/localization_provider.dart';
import '../../themes/colors.dart';
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
  @override
  void initState() {
    super.initState();
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
                width: 88.w,
                height: 33.h,
                child: box(
                    EdgeInsets.only(right: 15.w),
                    Text(
                      S.of(context).history,
                      style: const TextStyle(color: AppDarkColors.themeColor),
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
                      "xxxxxx",
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
                      hintText: '',
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
                  style: TextStyle(
                      fontSize: 12,
                      color: AppDarkColors.tabBarNormalColor.withOpacity(0.6)),
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
                Container(
                  width: 98,
                  height: 98,
                  decoration: const BoxDecoration(
                    color: Color(0xFF181818), // Background color
                    borderRadius:
                        BorderRadius.all(Radius.circular(8)), // Border radius
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppDarkColors.themeColor,
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () {
                    _showModalBottomSheet(context);
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

  //feedback_type1:意见 2:咨询 3:异常 4:其他, platform 1macos 2windows 3android 4ios
  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      // backgroundColor: Color(0x181818FF),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
      ),
      builder: (BuildContext context) {
        int selectindex = 1;
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
                                style: const TextStyle(color: Colors.black),
                              ),
                              color: const Color(0xFF52FF38),
                              radius: 40.0),
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
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
}
