import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constant.dart';
import '../../http/HttpService.dart';
import '../../l10n/generated/l10n.dart';
import '../../themes/colors.dart';
import '../../utils/shared_preferences.dart';
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
  List<Map<String, dynamic>> bugList = [];

  @override
  void initState() {
    _getBugsList();
    super.initState();
  }

  Future<void> _getBugsList() async {
    var code = TTSharedPreferences.getString(Constant.userCode) ?? "";
    var map = await HttpService().bugsList(code);

    if (map == null) {
      return;
    }
    List<Map<String, dynamic>> list = map["list"];
    if (list.isEmpty) {
      return;
    }

    bugList = list;
    setState(() {});
  }

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
            child: bugList.isEmpty
                ? const Center(
                    child: Text("暂无相关数据"),
                  )
                : ListView.builder(
                    itemCount: bugList.length, // 列表项的总数
                    itemBuilder: (context, index) {
                      var bean = bugList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FeedbackListDetailPage()),
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
                                Text('更新時間：${bean["updated_at"]}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            AppDarkColors.tabBarActiveColor)),
                                Spacer(),
                                Text('${bean["state"]}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppDarkColors.themeColor)),
                              ],
                            ),
                            title: Text('${bean["description"]}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color:
                                        AppDarkColors.titleColor)), // 构建每个列表项
                          ),
                        ),
                      );
                    },
                  )));
  }
}
