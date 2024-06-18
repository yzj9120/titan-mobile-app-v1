

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../http/HttpService.dart';
import '../providers/localization_provider.dart';
import 'marquee.dart';

class MyMarqueeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _myMarqueeState();
  }
}

class _myMarqueeState extends State<MyMarqueeWidget> {
  bool isShowMarquee = true;
  var list = [];

  @override
  void initState() {
    super.initState();
  }


  Future<void> getNotice() async {
    LocalizationProvider local =
    Provider.of<LocalizationProvider>(context, listen: false);
    final String lang = local.isEnglish() ? "en" : "cn";
    var map = await HttpService().notice(lang);
    if (map == null) {
      return;
    }
    list = map["list"];
  }

  MarqueeWidget buildMarqueeWidget(List<dynamic> loopList) {
    ///上下轮播 安全提示
    return MarqueeWidget(
      //子Item构建器
      itemBuilder: (BuildContext context, int index) {
        String itemStr = loopList[index]["Name"] ?? "";
        String url = loopList[index]["RedirectUrl"] ?? " ";
        //通常可以是一个 Text文本
        return  GestureDetector(
          onTap: () async {
            if (!await launchUrl(Uri.parse(url))) {
              throw Exception('Could not launch $url');
            }
          },
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              itemStr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
      //循环的提示消息数量
      count: loopList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return !isShowMarquee || list.isEmpty
        ? Container()
        : Column(
      children: [
        SizedBox(height: 30.h),
        Container(
          height: 40.h,
          width: 375.w,
          color: const Color(0xFF00FF00),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10.w),
              SizedBox(
                width: 310.w,
                child:  buildMarqueeWidget(list),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isShowMarquee = !isShowMarquee;
                  });
                },
                child: Icon(
                  Icons.highlight_off,
                  size: 15.w,
                ),
              ),
              SizedBox(width: 10.w),
            ],
          ),
        ),
      ],
    );
  }
}
