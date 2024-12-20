import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/homepage/component/recordListOfUsers.dart';
import 'package:pose_app/homepage/component/WebViewDialog.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/data.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartToStudyDetail extends StatefulWidget {
  const StartToStudyDetail({Key? key}) : super(key: key);

  @override
  _StartToStudyDetailState createState() => _StartToStudyDetailState();
}

class _StartToStudyDetailState extends State<StartToStudyDetail> {
  List<Map<String, dynamic>> recentActivities = [];
  List<Map<String, dynamic>> upcomingPayments = [];
  List<dynamic> records = [];
  bool isSwitched = false; // 定义一个状态变量

  @override
  void initState() {
    super.initState();
    // 在这里添加初始化逻辑，比如网络请求
    fetchAndInitialize();
  }

  Future<void> fetchAndInitialize() async {
    await fetchVideoUrl();
    await getUserRecords();
    initializeRecentActivities();
    initializaUpcomingPayments();
    setState(() {});
  }

  void initializeRecentActivities() {
    recentActivities.clear();
    print('recentActivities count: ${recentActivities.length}');
    print('Initialize Recent Activities');
    print('Records: $records');
    records.forEach((record) {
      int startTime;
      var startTimeValue = record['start_time'];
      if (startTimeValue is int) {
        startTime = startTimeValue;
      } else if (startTimeValue is double) {
        startTime = startTimeValue.toInt();
      } else {
        throw Exception(
            "Invalid type for start_time: ${startTimeValue.runtimeType}");
      }

      double sessionDuration = record['eye_times']['session_duration'];

      // 将Unix时间戳转换为日期时间
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(startTime * 1000);
      String formattedDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

      // 将session_duration转换为分钟和秒
      int minutes = (sessionDuration / 60).floor();
      double seconds = sessionDuration % 60;

      //将minutes和seconds截断为整数
      int minutes_int = minutes.toInt();
      int seconds_int = seconds.toInt();

      print('minutes: $minutes_int, seconds: $seconds_int');

      recentActivities.add({
        "icon": "assets/icons/User.svg",
        "label": "专注任务",
        "amount": "$minutes_int 分 $seconds_int 秒",
        "selectedDate": dateTime,
      });

      // 打印格式化后的数据
      // print(
      //     'Start Time: $formattedDateTime, Session Duration: $minutes min $seconds sec');
    });

    //将recentActivities顺序反转

    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        recentActivities = recentActivities.reversed.toList();
      });
    });
  }

  void initializaUpcomingPayments() {
    setState(() {
      upcomingPayments = [
        {"icon": 'assets/icons/Group.svg', "label": "专注任务1", "amount": "25分钟"},
        {"icon": 'assets/icons/Group.svg', "label": "专注任务2", "amount": "30分钟"},
      ];
    });
  }

  void updateRecentActivities() {
    // 遍历记录并提取和格式化数据
    records.forEach((record) {
      int startTime = record['start_time'];
      double sessionDuration = record['eye_times']['session_duration'];

      // 将Unix时间戳转换为日期时间
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(startTime * 1000);
      String formattedDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

      // 将session_duration转换为分钟和秒
      int minutes = (sessionDuration / 60).floor();
      double seconds = sessionDuration % 60;

      // 打印格式化后的数据
      print(
          'Start Time: $formattedDateTime, Session Duration: $minutes min $seconds sec');
    });
    setState(() {
      recentActivities.add({
        "icon": Icons.work,
        "label": "新任务",
        "amount": "20分钟",
        "selectedDate": DateTime.now(),
      });
    });
  }

  void updateUpcomingPayments() {
    setState(() {
      upcomingPayments.add({
        "icon": Icons.work,
        "label": "新任务",
        "amount": "20分钟",
      });
    });
  }

  fetchVideoUrl() async {
    // 模拟网络请求
    print('Video URL fetched');
  }

  Future<void> getUserRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAccessToken = prefs.getString('accessToken');
    if (storedAccessToken == null || storedAccessToken.isEmpty) {
      throw Exception('Access Token not found');
    }
    // 更新本地状态
    final access_token = storedAccessToken;

    print(' access_token in startToStudyDetail: $access_token');
    // 获取用户记录
    print('User records fetched');
    try {
      Dio dio = Dio();
      Response response = await dio.get(
        'http://8.217.68.60/records',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access_token', // 在请求头中添加 accessToken
        }), // 将 accessToken 添加到请求头
      );
      // print('Session Record: ${response.data}');
      print(response.data.runtimeType);
      print('record count: ${response.data.length}');
      records = response.data;
      // 将response.data作为JSON数据传递给POST请求
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 15, // 按钮上方的间距
        ),

        // 开始按钮组件
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 20),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return VideoDialog();
                String videoUrl = '';
                if (isSwitched) {
                  videoUrl = 'http://127.0.0.1:5000/video_feed';
                } else {
                  videoUrl = 'http://127.0.0.1:5000/video_feed_without_dots';
                }
                return VideoWebViewDialog(videoUrl: videoUrl);
              },
            );
          },
          child: Text("开始"),
        ),

        SizedBox(
          height: SizeConfig.blockSizeVertical! * 7, // 按钮下方的间距
        ),

        // 切换按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "显示",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value; // 更新状态
                });
              },
            ),
          ],
        ),

        // 按钮下方的间距
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 7, // 调整此值来增加下方的间距
        ),

        // 个人专注部分的记录列表
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
            ElevatedButton(
                onPressed: fetchAndInitialize, child: Icon(Icons.refresh)),
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
              selectedDate: recentActivities[index]["selectedDate"],
            ),
          ),
        ),

        // 集体专注记录
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
}
