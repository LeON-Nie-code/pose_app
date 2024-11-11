import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart'; 
import 'package:pose_app/homepage/component/recordListOfUsers.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/data.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';

class StartToStudyDetail extends StatefulWidget {
  const StartToStudyDetail({super.key});

  @override
  _StartToStudyDetailState createState() => _StartToStudyDetailState();
}

class _StartToStudyDetailState extends State<StartToStudyDetail> {
  final WebviewController webviewController = WebviewController();

  @override
  void initState() {
    super.initState();
    initializeWebView();
  }

  Future<void> initializeWebView() async {
    // 初始化 WebView 控制器并设置需要加载的 URL 或本地文件
    await webviewController.initialize();
    webviewController.loadUrl('https://www.example.com'); // 可以替换为实际 URL 或本地文件路径
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 10,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, 
            foregroundColor: Colors.black, 
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(fontSize: 20),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SizedBox(
                    width: 900,
                    height: 700,
                    child: webviewController.value.isInitialized
                        ? Webview(webviewController)
                        : Center(child: CircularProgressIndicator()), // 确保 WebView 初始化完成后显示
                  ),
                );
              },
            );
          },
          child: Text("开始"),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 10,
        ),
        
        // 个人专注部分的记录等内容...
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryText(
              text: '个人专注记录',
              size: 18,
              fontWeight: FontWeight.w800,
            ),
            PrimaryText(
              text: '02 Mar 20xx（例子）',
              size: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ],
        ),
        
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 2,
        ),
        
        Column(
          children: List.generate(
            recentActivities.length,
            (index) => RecordListOfUsers(
              icon: recentActivities[index]["icon"],
              label: recentActivities[index]["label"],
              amount: recentActivities[index]["amount"],
            ),
          ),
        ),

        // 集体专注
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 5,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryText(
              text: '集体专注记录',
              size: 18,
              fontWeight: FontWeight.w800,
            ),
            PrimaryText(
              text: '02 Mar 2021（例子）',
              size: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ],
        ),
      
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 2,
        ),
        
        Column(
          children: List.generate(
            upcomingPayments.length,
            (index) => RecordListOfUsers(
              icon: upcomingPayments[index]["icon"],
              label: upcomingPayments[index]["label"],
              amount: upcomingPayments[index]["amount"],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    webviewController.dispose(); // 销毁 WebView 控制器
    super.dispose();
  }
}