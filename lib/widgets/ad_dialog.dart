import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:titan_app/ext/visibility_ext.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../config/constant.dart';
import '../http/HttpService.dart';
import '../l10n/generated/l10n.dart';
import '../providers/localization_provider.dart';
import '../utils/shared_preferences.dart';
import 'confirm_dialog.dart';
import 'flutter_swiper/swiper.dart';
import 'flutter_swiper/swiper_controller.dart';
import 'flutter_swiper/swiper_pagination.dart';
import 'flutter_swiper/swiper_plugin.dart';

class AdDialog {
  static Future<void> adDialog(BuildContext context, {Function? onCall}) async {

    LocalizationProvider local =
    Provider.of<LocalizationProvider>(context, listen: false);

    final String lang = local.isEnglish() ? "en" : "cn";
    var map = await HttpService().banners(lang);

    int timestamp1 = TTSharedPreferences.getInt(Constant.adNextTimestamp) ?? 0;
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime dateTime1 = DateTime.fromMillisecondsSinceEpoch(timestamp1);
    // DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(currentTimestamp);
    DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(1718705179000);
    Duration difference = dateTime2.difference(dateTime1);

    if (difference.inHours > 24) {
    } else {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool _isChecked = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: false,
              child: Material(
                color: Colors.transparent.withOpacity(0.5),
                child: Center(
                  child: SizedBox(
                    height: 350.w,
                    width: 375.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            const CustomViewBanner(),
                            Positioned(
                              right: 5.w,
                              top: 5.w,
                              child: GestureDetector(
                                onTap: () async {
                                  if (_isChecked) {
                                    await TTSharedPreferences.setInt(
                                        Constant.adNextTimestamp,
                                        DateTime.now()
                                            .millisecondsSinceEpoch);
                                  }
                                  Navigator.of(context).pop();
                                  // ConfirmDialog.create(context,
                                  //     onCall: (type) async {
                                  //   if (type) {
                                  //
                                  //   }
                                  // });
                                },
                                child: Image.asset(
                                  "assets/images/common_icons_close.png",
                                  width: 20.w,
                                  height: 20.w,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(()  {
                              _isChecked = !_isChecked;
                              Navigator.of(context).pop();
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                _isChecked
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank,
                                //check_box_outline_blank
                                color: Colors.white,
                                size: 15.w,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                S.of(context).t24TimeNotShow,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CustomViewBanner extends StatefulWidget {
  const CustomViewBanner({super.key});

  @override
  State<StatefulWidget> createState() => _CustomBannerViewState();
}

class _CustomBannerViewState extends State<CustomViewBanner>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final SwiperController _swiperController = SwiperController();
  var jsonData = [
    {
      "id": 1,
      "type": 0,
      "name": "banner图",
      "image":
          "http://gips3.baidu.com/it/u=3886271102,3123389489&fm=3028&app=3028&f=JPEG&fmt=auto?w=1280&h=960",
      "link": "https://www.baidu.com/"
    },
    {
      "id": 1,
      "type": 0,
      "name": "banner图",
      "image":
          "http://gips3.baidu.com/it/u=3886271102,3123389489&fm=3028&app=3028&f=JPEG&fmt=auto?w=1280&h=960",
      "link": "https://www.baidu.com/"
    },
    {"id": 2, "type": 1, "name": "跑马灯", "image": "图片地址", "link": "跳转地址"},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SwiperPlugin swiperPlugin = DotSwiperPaginationBuilder(
      color: Colors.white54,
      activeColor: const Color(0xFF00FF00),
      size: 8.w,
      activeSize: 8.w,
      // activeSize: 8,
    );

    final List<Map<String, dynamic>> typeZeroData =
        jsonData.where((item) => item['type'] == 0).toList();

    List<Widget> itemArray = typeZeroData.map((e) {
          return RepaintBoundary(
            child: GestureDetector(
              onTap: () async {
                var url = e["link"];
                if (!await launchUrl(Uri.parse(url))) {
                  throw Exception('Could not launch $url');
                }
              },
              child:CachedNetworkImage(
                imageUrl: e["image"],
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                placeholder: (context, str) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white10,
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.white10,
                    ),
                  );
                },
              ),
            ),
          );
        }).toList() ??
        [];
    return VisibilityDetector(
        key: ValueKey(identityHashCode(this)),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.isVisible()) {
            _swiperController.startAutoplay();
          } else {
            _swiperController.stopAutoplay();
          }
        },
        child: Container(
          height: 255.w,
          width: 375.w,
          margin: EdgeInsets.all(15.w),
          color: const Color(0x00000000),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0), // Set the desired bord
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return itemArray[index];
              },
              itemCount: typeZeroData.length,
              // 选中时的指示器
              pagination: SwiperPagination(
                alignment: Alignment.bottomCenter,
                builder: swiperPlugin,
                margin: EdgeInsets.only(bottom: 10.w),
              ),
              control: null,
              controller: _swiperController,
              duration: 150,
              scrollDirection: Axis.horizontal,
              viewportFraction: 1,
              autoplay: true,
              onTap: (int index) {},
            ),
          ),
        ));
  }
}
