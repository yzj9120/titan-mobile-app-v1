import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:titan_app/config/appConfig.dart';
import 'package:titan_app/providers/version_provider.dart';
import 'package:titan_app/themes/colors.dart';
import 'package:titan_app/utils/system_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../ads/ad_dialog.dart';
import '../../ads/marquee_widget.dart';
import '../../bridge/bridge_mgr.dart';
import '../../config/constant.dart';
import '../../l10n/generated/l10n.dart';
import '../../providers/ads_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/NetworkManager.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/utility.dart';
import '../../widgets/common_text_widget.dart';
import '../../widgets/loading_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final double kImageSize = 300.w;
  double money = 0.0;

  //late VideoPlayerController _prepareController;
  late VideoPlayerController _runningController;

  // late Future<void> _initializePrepareVideoPlayerFuture;
  late Future<void> _initializeRunningVideoPlayerFuture;

  late final AppLifecycleListener _appLifecyclelistener;

  Duration loopStart = const Duration(seconds: 3);
  Duration prepareStart = const Duration(seconds: 0);

  bool isDaemonRunning = false;
  bool isDaemonOnline = false;

  int daemonCounter = 0;
  bool isClickHandling = false;
  bool _isActivating = false;
  Timer? timer;
  bool isQuerying = false;

  bool isShowWifiDialog = false;

  BuildContext? _dialogContext;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    isDaemonOnline = BridgeMgr().daemonBridge.isDaemonOnline;
    _appLifecyclelistener = AppLifecycleListener(
      onResume: () => _handleTransition('resume'),
      onInactive: () => _handleTransition('inactive'),
      onRestart: () => _handleTransition('restart'),
    );
    _runningController =
        VideoPlayerController.asset('assets/videos/running.mp4');
    _runningController.setLooping(true);
    _initializeRunningVideoPlayerFuture = _runningController.initialize();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AdDialog.adDialog(context, 0);
      BridgeMgr().minerBridge.minerInfo.addListener("income", "home_page", () {
        setState(() {
          money = BridgeMgr().minerBridge.minerInfo.todayIncome();
        });
      });
    });
    _networkListen();
    _startActivation();

    Provider.of<LocalizationProvider>(context, listen: false).addListener(() {
      AdDialog.adDialog(context, 0);
    });
  }

  @override
  void dispose() {
    _stopActivation();
    // _prepareController.dispose();
    _runningController.dispose();
    _appLifecyclelistener.dispose();
    BridgeMgr().minerBridge.minerInfo.removeListener("income", "home_page");
    super.dispose();
  }

  double isVisible() {
    return !isDaemonOnline ? 0.0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final String versionName =
        Provider.of<VersionProvider>(context, listen: false).localVersion;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 144.h,
              left: (MediaQuery.of(context).size.width - kImageSize - 40.w) /
                  2, //40 buffer
              child: SizedBox(
                width: kImageSize,
                height: kImageSize,
                child: _imageNode(context),
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 137.h,
                ),
                _todayEarnings(context),
                // SizedBox(
                //   height: 20.h,
                // ),
                // _imageNode(context),
                SizedBox(
                  height: 220.h,
                ),
                Text(
                  S.of(context).current_device_ID,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFAFAFA),
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  BridgeMgr().daemonBridge.daemonCfgs.id(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF909090),
                  ),
                ),
                SizedBox(
                  height: SystemUtils.isIOS ? 100.h : 120.h,
                ),
                _startButton(context),
                SizedBox(
                  height: 12.h,
                ),
                _earningInfoButton(context),
                SizedBox(
                  height: 32.h,
                ),
                CommonTextWidget(
                  versionName,
                  fontSize: FontSize.extraSmall,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
            Consumer<AdsProvider>(
              builder: (context, adsProvider, child) {
                return adsProvider.banners.isEmpty
                    ? Container()
                    : Positioned(
                        top: 30.h,
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            AdDialog.adDialog(context, 1);
                          },
                          icon: const Icon(
                            Icons.notifications_sharp,
                            color: Colors.white,
                          ),
                        ),
                      );
              },
            ),
            MyMarqueeWidget(),
          ],
        ),
      ),
    );
  }

  Future<void> toMoneyDetailPage() async {
    if (!isDaemonOnline) {
      return;
    }
    var baseurl = AppConfig.nodeInfoURL;
    String url = '$baseurl${BridgeMgr().daemonBridge.daemonCfgs.id()}';
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _todayEarnings(BuildContext context) {
    return Opacity(
        opacity: isVisible(),
        child: RichText(
          text: TextSpan(
            text: S.of(context).today_earnings,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14.0.sp),
            children: [
              TextSpan(
                  text: ' ${money.toStringAsFixed(3)} ',
                  style: TextStyle(
                      color: AppDarkColors.themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0.sp),
                  children: [
                    TextSpan(
                        text: BridgeMgr().minerBridge.minerInfo.tokenUnit(),
                        style: TextStyle(
                            color: AppDarkColors.titleColor, fontSize: 14.0.sp))
                  ])
            ],
          ),
        ));
  }

  Widget _imageNode(BuildContext context) {
    // if (!isDaemonRunning) {
    //   return Image.asset(
    //     "assets/images/mobile_node_stop.png",
    //     fit: BoxFit.contain,
    //   );
    // }
    if (!isDaemonOnline) {
      return _startPrepareNode(context);
    } else {
      return _startRunningNode(context);
    }
  }

  void _networkListen() {
    NetworkManager().initialize();
    NetworkManager().connectivityStream.listen((result) async {
      bool isConnected = await NetworkManager().isConnected();
      bool isConnectedToWiFi = await NetworkManager().isConnectedToWiFi();
      if (_dialogContext != null &&
          _dialogContext!.mounted &&
          isConnectedToWiFi &&
          isShowWifiDialog) {
        Navigator.of(_dialogContext!).pop();
      }
      if (!isConnectedToWiFi &&
          !isShowWifiDialog &&
          isDaemonOnline &&
          isConnected) {
        var has4gRun = TTSharedPreferences.getBool(Constant.has4gRun) ?? true;
        print("network:is run :$has4gRun");
        if (!has4gRun) {
          await BridgeMgr().daemonBridge.stopDaemon();
          return;
        } else {
          _wifiDialog(S.of(context).disableNode, onCall: (type) async {
            if (isDaemonOnline && type) {
              _onAction();
            }
          });
        }
      }
    });
  }

  Future<void> _wifiDialog(String des, {Function? onCall}) async {
    isShowWifiDialog = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171717), // 设置背景颜色
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
      ),
      builder: (BuildContext context) {
        _dialogContext = context;
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          margin: EdgeInsets.all(15.w),
          child: Column(children: [
            SizedBox(height: 20.h),
            Image.asset(
              "assets/images/icon_wifi_open.png",
              width: 90.w,
              height: 90.w,
            ),
            SizedBox(height: 20.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(S.of(context).currentResource,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(true);
                onCall?.call(true);
              },
              child: Container(
                width: 335.w,
                height: 48.h,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF52FF38), // Background color
                  borderRadius:
                      BorderRadius.all(Radius.circular(85)), // Border radius
                ),
                child: Text(
                  S.of(context).stillrunning,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(false);
                onCall?.call(false);
              },
              child: Container(
                width: 335.w,
                height: 48.h,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white12, // Background color
                  borderRadius:
                      BorderRadius.all(Radius.circular(85)), // Border radius
                ),
                child: Text(
                  S.of(context).cancel,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            )
          ]),
        );
      },
    ).then((value) {
      _dialogContext = null;
      isShowWifiDialog = false;
      isClickHandling = false;
    });
  }

  void _startActivation() {
    if (_isActivating) {
      return;
    }

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
      await queryDaemonState();
    });

    BridgeMgr().minerBridge.startActivationg();
    _updateAnimation();

    _isActivating = true;
  }

  void _stopActivation() {
    timer?.cancel();
    BridgeMgr().minerBridge.stopActivation();

    // _prepareController.pause();
    _runningController.pause();

    _isActivating = false;
  }

  void _handleTransition(String name) {
    switch (name) {
      case "resume":
        _startActivation();
        break;
      case "inactive":
        _stopActivation();
        break;
      case "restart":
        _startActivation();
        break;
    }
  }

  void _updateAnimation() {
    const Duration zero = Duration(seconds: 0);
    _runningController.seekTo(zero);
    _runningController.pause();
    // _prepareController.seekTo(zero);
    // _prepareController.pause();

    if (isDaemonOnline) {
      _runningController.play();
    }
  }

  Widget _startPrepareNode(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Image.asset("assets/images/mobile_node_stop.png",
          fit: BoxFit.contain),
    );
  }

  Widget _startRunningNode(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: FutureBuilder(
          future: _initializeRunningVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (isDaemonOnline) {
                return AspectRatio(
                  aspectRatio: _runningController.value.aspectRatio * 1,
                  child: VideoPlayer(_runningController),
                );
              } else {
                return Image.asset("assets/images/mobile_node_stop.png",
                    fit: BoxFit.contain);
              }
            } else {
              return Image.asset("assets/images/mobile_node_stop.png",
                  fit: BoxFit.contain);
            }
          }),
    );
  }

  Widget _startButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        handleStartStopClick(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: (!isDaemonOnline)
            ? AppDarkColors.themeColor
            : const Color(0xff181818),
        minimumSize: Size(335.w, 48.h),
      ),
      child: Text(
        (!isDaemonOnline)
            ? S.of(context).start_earning_coins
            : S.of(context).stop_earning_coins,
        style: TextStyle(
            color: (!isDaemonOnline)
                ? AppDarkColors.backgroundColor
                : AppDarkColors.grayColor,
            fontSize: 18.sp),
      ),
    );
  }

  Widget _earningInfoButton(BuildContext context) {
    return Opacity(
        opacity: isVisible(),
        child: ElevatedButton(
          onPressed: toMoneyDetailPage,
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(85.0),
                side: const BorderSide(color: AppDarkColors.themeColor),
              ),
            ),
            minimumSize: MaterialStateProperty.all<Size>(Size(335.w, 48.h)),
            elevation: MaterialStateProperty.all<double>(5),
            overlayColor: MaterialStateProperty.all<Color>(
                Colors.lightBlueAccent.withOpacity(0.5)),
          ),
          child: Text(
            S.of(context).view_earnings_details,
            style: TextStyle(color: AppDarkColors.themeColor, fontSize: 18.sp),
          ),
        ));
  }

  void handleSignClick() async {
    var ret = await BridgeMgr().daemonBridge.sign("abc");
    debugPrint('handleSignClick: $ret');
  }

  Future<void> queryDaemonState() async {
    if (isQuerying) {
      return;
    }

    // if is click by user, stop query
    if (isClickHandling) {
      return;
    }

    isQuerying = true;
    String result;

    result = await BridgeMgr().daemonBridge.daemonState();

    debugPrint('~~~state call: $result');

    isQuerying = false;

    var jsonResult = jsonDecode(result);
    bool isOnline = false;
    bool isRunning = false;

    if (jsonResult["code"] == 0) {
      isRunning = true;
      final data = jsonDecode(jsonResult["data"]);
      bool online = data["online"];
      bool running = data["running"];
      isOnline = online;

      if (BridgeMgr().daemonBridge.daemonCfgs.id() == "") {
        await BridgeMgr().daemonBridge.loadDaemonConfig();
        // update node info
        var cfg = BridgeMgr().daemonBridge.daemonCfgs;
        BridgeMgr().minerBridge.setNodeInfo(cfg.id(), cfg.areaID());
        // pull data from server
        BridgeMgr().minerBridge.pullInfo();
      }
      debugPrint('~~~是否重新发起重连l:');
      /// 如果是自动断开 重新发起重连 ：：：：可以去掉  go层已经实现了 断开后自动重连
      if (!running || !online) {
        bool isConnectedToWiFi = await NetworkManager().isConnectedToWiFi();
        if(isConnectedToWiFi){
          var res = await BridgeMgr().daemonBridge.startDaemon();
          debugPrint('~~~重新发起重连l: $res');
        }else{
          var has4gRun = TTSharedPreferences.getBool(Constant.has4gRun) ?? true;
          if (has4gRun) {
            var res = await BridgeMgr().daemonBridge.startDaemon();
            debugPrint('~~~重新发起重连l: $res');
          } else {
            debugPrint('~~~不用重新发起重连');
          }
        }
      }
    }

    if (isDaemonOnline == isRunning && isDaemonOnline == isOnline) {
      return;
    }

    if (isOnline != isDaemonOnline) {
      if (isOnline) {
        // pull data from server imm
        BridgeMgr().minerBridge.pullInfo();
      } else {
        // if it is offline, stop increase incoming
        if (isDaemonOnline) {
          BridgeMgr().minerBridge.minerInfo.clearIncomeIncr();
        }
      }
    }

    setState(() {
      isDaemonRunning = isRunning;
      isDaemonOnline = isOnline;
      _updateAnimation();
    });
  }

  void showNetworkSnackBar(BuildContext context) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: S.of(context).networkNotConnected,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  void handleStartStopClick(BuildContext context) async {
    print("handleStartStopClick.....$isClickHandling");

    if (isClickHandling) {
      return;
    }
    isClickHandling = true;

    bool isConnected = await NetworkManager().isConnected();
    if (!isConnected) {
      showNetworkSnackBar(context);
      isClickHandling = false;
      return;
    }
    bool isConnectedToWiFi = await NetworkManager().isConnectedToWiFi();

    print("network:isConnectedToWiFi=$isConnectedToWiFi");
    if (!isConnectedToWiFi && !isShowWifiDialog && !isDaemonOnline) {
      print("network:isConnectedToWiFi...ok");

      _wifiDialog(S.of(context).enableNode, onCall: (type) async {
        isClickHandling = false;
        if (type) {
          _onAction();
        }
      });
    } else {
      _onAction();
    }
  }

  Future<void> _onAction() async {
    Map<String, dynamic> result;
    String action;
    final String indicatorMsg =
        isDaemonOnline ? S.of(context).stopping : S.of(context).starting;

    print("network:_onAction.....");
    LoadingIndicator.show(context, message: indicatorMsg);
    if (isDaemonOnline) {
      result = await BridgeMgr().daemonBridge.stopDaemon();
      action = "Stop daemon";
    } else {
      result = await BridgeMgr().daemonBridge.startDaemon();
      action = "Start daemon";
    }
    if (context.mounted) {
      LoadingIndicator.hide(context);
    }
    isClickHandling = false;
    debugPrint('start/stop call, action:$action, result: $result');
    if (result["bool"]) {
      setState(() {
        isDaemonOnline = !isDaemonOnline;
        _updateAnimation();
      });
    } else {
      if (context.mounted && !isDaemonOnline && !isDaemonRunning) {
        String msg = result["r"];
        Indicators.showMessage(context, action, msg, null, null);
      }
    }
  }
}
