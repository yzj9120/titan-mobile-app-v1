import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:titan_app/config/appConfig.dart';
import 'package:titan_app/providers/version_provider.dart';
import 'package:titan_app/themes/colors.dart';
import 'package:titan_app/utils/system_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../bridge/bridge_mgr.dart';
import '../../l10n/generated/l10n.dart';
import '../../utils/NetworkManager.dart';
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

  // bool isDaemonRunning = false;
  bool isDaemonOnline = false;

  int daemonCounter = 0;
  bool isClickHandling = false;
  bool _isActivating = false;
  Timer? timer;
  bool isQuerying = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // isDaemonRunning = BridgeMgr().daemonBridge.isDaemonRunning;
    isDaemonOnline = BridgeMgr().daemonBridge.isDaemonOnline;

    _appLifecyclelistener = AppLifecycleListener(
      onResume: () => _handleTransition('resume'),
      onInactive: () => _handleTransition('inactive'),
      onRestart: () => _handleTransition('restart'),
      // This fires for each state change. Callbacks above fire only for
      // specific state transitions.
      //onStateChange: _handleStateChange,
    );

    // _prepareController =
    //     VideoPlayerController.asset('assets/videos/prepare.mp4');
    _runningController =
        VideoPlayerController.asset('assets/videos/running.mp4');
    // _prepareController.setLooping(true);
    _runningController.setLooping(true);
    // _initializePrepareVideoPlayerFuture = _prepareController.initialize();
    _initializeRunningVideoPlayerFuture = _runningController.initialize();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BridgeMgr().minerBridge.minerInfo.addListener("income", "home_page", () {
        setState(() {
          money = BridgeMgr().minerBridge.minerInfo.todayIncome();
        });
      });
    });

    NetworkManager().initialize();
    NetworkManager().connectivityStream.listen((result) async {
      bool isConnectedToWiFi = await NetworkManager().isConnectedToWiFi();
      ;
      if (_dialogContext != null &&
          _dialogContext!.mounted &&
          isConnectedToWiFi &&
          isShowWifiDialog) {
        Navigator.of(_dialogContext!).pop();
      }
      if (!isConnectedToWiFi && !isShowWifiDialog && isDaemonOnline) {
        _wifiDialog(S.of(context).disableNode, onCall: (type) async {
          if (isDaemonOnline) {
            _onAction();
          }
        });
      }
    });

    _startActivation();
  }

  bool isShowWifiDialog = false;

  BuildContext? _dialogContext = null;

  void _wifiDialog(String des, {Function? onCall}) {
    isShowWifiDialog = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _dialogContext = context;
        return AlertDialog(
          backgroundColor: const Color(0xff181818),
          contentPadding: EdgeInsets.zero,
          title: Text(
            S.of(context).gentleReminder,
            style: const TextStyle(),
          ),
          content: Container(
            margin: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.8,
            height: 80.w,
            child: Text(des, style: const TextStyle(fontSize: 14)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                onCall?.call(false);
              },
              child: Text(S.of(context).cancel,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onCall?.call(true);
              },
              child: Text(S.of(context).confirm,
                  style: const TextStyle(fontSize: 14, color: Colors.green)),
            ),
          ],
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
      isOnline = online;

      if (BridgeMgr().daemonBridge.daemonCfgs.id() == "") {
        await BridgeMgr().daemonBridge.loadDaemonConfig();
        // update node info
        var cfg = BridgeMgr().daemonBridge.daemonCfgs;
        BridgeMgr().minerBridge.setNodeInfo(cfg.id(), cfg.areaID());
        // pull data from server
        BridgeMgr().minerBridge.pullInfo();
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
      isDaemonOnline = isRunning;
      isDaemonOnline = isOnline;
      _updateAnimation();
    });
  }

  void handleStartStopClick(BuildContext context) async {
    if (isClickHandling) {
      return;
    }
    isClickHandling = true;
    bool isConnectedToWiFi = await NetworkManager().isConnectedToWiFi();
    if (!isConnectedToWiFi && !isShowWifiDialog && !isDaemonOnline) {
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
      if (context.mounted) {
        String msg = result["r"];
        Indicators.showMessage(context, action, msg, null, null);
      }
    }
  }
}
