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
import 'feedback_list_detail_page.dart';

class FeedbackListPage extends StatefulWidget {
  const FeedbackListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FeedbackListState();
  }
}

class _FeedbackListState extends State<FeedbackListPage> {
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
            margin: EdgeInsets.symmetric(horizontal: 15.w),
            child: ListView.builder(
              itemCount: items.length, // 列表项的总数
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeedbackListDetailPage()),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white10,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: ListTile(
                      subtitle: Row(
                        children: [
                          Text('更新時間：20240616 23:23',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppDarkColors.tabBarActiveColor)),
                          Spacer(),
                          Text('待处理',
                              style: const TextStyle(
                                  fontSize: 12, color: AppDarkColors.themeColor)),
                        ],
                      ),
                      title:Text('${items[index]}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppDarkColors.titleColor)
                      ), // 构建每个列表项
                    ),
                  ),
                );
              },
            )));
  }
}
