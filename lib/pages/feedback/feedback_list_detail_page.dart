import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:titan_app/config/appConfig.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../http/HttpService.dart';
import '../../l10n/generated/l10n.dart';
import '../../providers/localization_provider.dart';
import '../../themes/colors.dart';
import '../../widgets/common_text_widget.dart';

class FeedbackListDetailPage extends StatefulWidget {
  const FeedbackListDetailPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FeedbackListDetailState();
  }
}

class _FeedbackListDetailState extends State<FeedbackListDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items = List<String>.generate(100, (i) => "Item $i");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: CommonTextWidget(
            S.of(context).history,
            fontSize: FontSize.large,
          ),
          iconTheme: const IconThemeData(color: AppDarkColors.iconColor),
          centerTitle: true,
          backgroundColor: AppDarkColors.backgroundColor,
        ),
        body: Container(
            margin: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 88.w,
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF181818),
                        borderRadius:
                        BorderRadius.all(Radius.circular(34.w)), // 圆角边框
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '待处理',
                        style: TextStyle(
                          color: AppDarkColors.themeColor,
                        ),
                      ),
                    ),
                    Spacer(),
                    Image.asset(
                      "assets/images/icon_jiangli.png",
                      width: 18,
                      height: 18,
                    ),
                    Text('奖励：TNT2 +100',
                        style: const TextStyle(
                            fontSize: 12, color: AppDarkColors.themeColor)),
                    SizedBox(height: 10.h),
                  ],
                ),
                SizedBox(height: 15.h),
                Text('更新時間：20240616 23:23',
                    style: const TextStyle(
                        fontSize: 12, color: AppDarkColors.tabBarActiveColor)),
                SizedBox(height: 10.h),
                Container(
                  width: 340.w,
                  // height: 106.h,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF181818), // 背景颜色
                    borderRadius: BorderRadius.all(Radius.circular(8)), // 圆角边框
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "${S.of(context).nodeId}:",
                            style: TextStyle(
                                fontSize: 12,
                                color: AppDarkColors.tabBarNormalColor
                                    .withOpacity(0.6)),
                          ),
                          const Text(
                            "xxxxxx",
                            style: TextStyle(
                                fontSize: 14,
                                color: AppDarkColors.tabBarNormalColor),
                          )
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Text(
                            "${S.of(context).email}:",
                            style: TextStyle(
                                fontSize: 12,
                                color: AppDarkColors.tabBarNormalColor
                                    .withOpacity(0.6)),
                          ),
                          const Text(
                            "xxxxxx",
                            style: TextStyle(
                                fontSize: 14,
                                color: AppDarkColors.tabBarNormalColor),
                          )
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Text(
                            "${S.of(context).setting_telegram}:",
                            style: TextStyle(
                                fontSize: 12,
                                color: AppDarkColors.tabBarNormalColor
                                    .withOpacity(0.6)),
                          ),
                          const Text(
                            "xxxxxx",
                            style: TextStyle(
                                fontSize: 14,
                                color: AppDarkColors.tabBarNormalColor),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                Text('问题描述',
                    style: const TextStyle(
                        fontSize: 12, color: AppDarkColors.tabBarActiveColor)),
                SizedBox(height: 15.h),
                Container(
                  width: 340.w,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF181818), // 背景颜色
                    borderRadius: BorderRadius.all(Radius.circular(8)), // 圆角边框
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${S.of(context).setting_telegram}:",
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            AppDarkColors.tabBarNormalColor.withOpacity(0.6)),
                  ),
                ),
                Expanded(
                    child: GridView.builder(
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: 30,
                  // 项目总数
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Image.network("https://imagepphcloud.thepaper.cn/pph/image/310/833/217.jpg"),
                    );
                  },
                ))
              ],
            )));
  }
}
