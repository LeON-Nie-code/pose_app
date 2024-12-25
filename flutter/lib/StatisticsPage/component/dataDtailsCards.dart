import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pose_app/StatisticsPage/component/calendarWidget.dart';
import 'package:pose_app/StatisticsPage/component/custom_card.dart';
import 'package:pose_app/statistic_data.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/StatisticsPage/component/pieChart.dart';
import 'package:pose_app/style/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pose_app/config/config.dart';

class DataDetailsCard extends StatefulWidget {
  final StudyDetails studyDetails; // 将成员变量作为构造函数参数传递

  DataDetailsCard({Key? key, required this.studyDetails}) : super(key: key);

  @override
  _DataDetailsCardState createState() => _DataDetailsCardState();
}

class _DataDetailsCardState extends State<DataDetailsCard> {
  // 在这里定义需要在状态中管理的变量
  List<dynamic> records = [];
  DateTime? selectedDate;
  Map<String, dynamic> selectedDateData = {
    'targetDateRecords': 0,
    'targetDateDuration': 0.0,
  };

  @override
  void initState() {
    super.initState();
    // 初始化状态
    fetchAndInitialize();
  }

  Future<void> fetchAndInitialize() async {
    await getUserRecords(); // 等待记录获取完成
    //initializaStudyDetails(); // 数据拉取后初始化StudyDetails
    setState(() {
      initializaStudyDetails();
    });
  }

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      selectedDateData = analyzeData(records, selectedDate);
    });
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Map<String, dynamic> analyzeData(
      List<dynamic> records, DateTime? targetDate) {
    Map<String, dynamic> result = {
      'totalRecords': 0,
      'todayRecords': 0,
      'totalDuration': 0.0,
      'todayDuration': 0.0,
      'targetDateRecords': 0,
      'targetDateDuration': 0.0,
      'postureAbnormalDuration': 0.0,
    };

    // 获取今天的日期
    DateTime today = DateTime.now();

    print('Today: $today');
    // DateTime recordDate;

    for (var record in records) {
      String createdAt = record['created_at'];

      // 使用DateFormat解析RFC 2822格式的日期字符串
      DateFormat format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
      DateTime recordDate;

      try {
        recordDate = format.parse(createdAt);
      } catch (e) {
        print('Error parsing date: $e');
        continue; // 跳过这个记录
      }

      // 解析记录的日期
      // recordDate = DateTime.parse(record['created_at']);

      // 累积总数据
      result['totalRecords'] += 1;
      result['totalDuration'] += record['duration'];

      // 累积今日数据
      if (isSameDay(recordDate, today)) {
        result['todayRecords'] += 1;
        result['todayDuration'] += record['duration'];
      }

      Map<String, dynamic> postureTimes = record['posture_times'] ?? {};

      double sessionDuration =
          postureTimes['session_duration'] ?? record['duration'];

      // 计算坐姿异常总时长
      double postureAbnormalDuration =
          ((postureTimes['lying down in the chair'] ?? 0.0) +
                  (postureTimes['left tilt'] ?? 0.0) +
                  (postureTimes['right tilt'] ?? 0.0))
              .clamp(0.0, sessionDuration);

      // 累积指定日期的数据
      if (targetDate != null && isSameDay(recordDate, targetDate)) {
        // result['targetDateRecords'] ??= 0;
        // result['targetDateDuration'] ??= 0.0;
        result['targetDateRecords'] += 1;
        result['targetDateDuration'] += record['duration'];
        print('Updated targetDateDuration: ${result['targetDateDuration']}');

        //计算坐姿异常
        result['postureAbnormalDuration'] =
            (result['postureAbnormalDuration'] + postureAbnormalDuration)
                .clamp(0.0, result['targetDateDuration']);
      }
    }

    return result;
  }

  void initializaStudyDetails() {
    // Map<String, dynamic> data = {
    //   'totalRecords': 0,
    //   'todayRecords': 0,
    //   'totalDuration': 0.0,
    //   'todayDuration': 0.0,
    // };
    print('!!!!!!!!!!!!!!Initializing Study Details with records: $records');

    Map<String, dynamic> data = analyzeData(records, null);

    print('Data: $data');

    // 更新数据

    // 更新累计数据
    setState(() {
      widget.studyDetails.aboutTotalData[0] = StudyDataModel(
        title: "次数",
        data: {"value": "${data['totalRecords'].toString()} 次"},
      );
      widget.studyDetails.aboutTotalData[1] = StudyDataModel(
        title: "时长",
        data: {
          "totalHour": "${(data['totalDuration'] / 60).toStringAsFixed(2)} 分钟"
        },
      );
      widget.studyDetails.aboutTotalData[2] = StudyDataModel(
        title: "次均时长",
        data: {
          "totalAverage": (() {
            // 检查数据有效性
            if (data['totalDuration'] != null &&
                data['totalRecords'] != null &&
                data['totalRecords'] > 0) {
              // 计算次均时长
              return "${(data['totalDuration'] / (60 * data['totalRecords'])).toStringAsFixed(2)} 分钟";
            } else {
              // 数据无效时返回默认值
              return "数据不足";
            }
          })(),
        },
      );

      // 更新今日数据
      widget.studyDetails.aboutTodayData[0] = StudyDataModel(
        title: "次数",
        data: {"todayValue": "${data['todayRecords'].toString()} 次"},
      );
      widget.studyDetails.aboutTodayData[1] = StudyDataModel(
        title: "时长",
        data: {
          "todayHour": "${(data['todayDuration'] / 60).toStringAsFixed(2)} 分钟"
        },
      );
      widget.studyDetails.aboutTodayData[2] = StudyDataModel(
        title: "次均时长",
        data: {
          "todayAverage": (() {
            // 检查数据有效性
            if (data['todayDuration'] != null &&
                data['todayRecords'] != null &&
                data['todayRecords'] > 0) {
              // 计算次均时长
              return "${(data['todayDuration'] / (60 * data['todayRecords'])).toStringAsFixed(2)} 分钟";
            } else {
              // 数据无效时返回默认值
              return "数据不足";
            }
          })(),
        },
      );
    });
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
        '${Config.baseUrl}/records',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access_token', // 在请求头中添加 accessToken
        }), // 将 accessToken 添加到请求头
      );
      print('Session Record: ${response.data}');
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
    SizeConfig().init(context); // 初始化屏幕尺寸配置

    Map<DateTime, List<String>> _eventDates = {};
    for (var record in records) {
      String createdAt = record['created_at'];
      DateFormat format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
      try {
        DateTime recordDate = format.parse(createdAt);
        // 确保键是标准化日期
        DateTime normalizedDate =
            DateTime(recordDate.year, recordDate.month, recordDate.day);
        _eventDates.putIfAbsent(normalizedDate, () => ["Recorded"]);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    print("_eventDates: $_eventDates"); // 调试日志

    String todayDateOfHeader = DateFormat('今天：MM月dd日').format(DateTime.now());
    return Container(
      height: MediaQuery.of(context).size.height, // 设置父容器高度以支持滚动
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
        child: Column(
          children: [
            // 标题
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryText(
                      text: '专注数据统计',
                      size: 30,
                      fontWeight: FontWeight.w800,
                    ),
                    PrimaryText(
                      text: todayDateOfHeader,
                      size: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
                SizedBox(width: 27,),
                FloatingActionButton(
                  onPressed: fetchAndInitialize,
                  child: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    ),
                  backgroundColor: AppColors.refreshButton,
                ),
              ],
            ),
            SizedBox(height: SizeConfig.blockSizeVertical! * 2),

////////////////// 第一个container "累计专注" //////////////////
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              width: double.infinity,
              height: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 3),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PrimaryText(
                      text: "累计专注",
                      size: 14.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warmOrange,
                    ),
                  ),
                  Wrap(
                    runSpacing: 20.0, // 垂直间距
                    spacing: 30.0, // 水平间距
                    alignment: WrapAlignment.spaceBetween, // 均匀分布
                    children: widget.studyDetails.aboutTotalData.map((model) {
                      return SizedBox(
                        child: CustomCard(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  model.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.warmOrange,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Gen-light',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  model.data.values.first,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.warmOrange,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 2),

////////////////// 第二个container "今日专注" //////////////////
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              width: double.infinity,
              height: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 3),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PrimaryText(
                      text: "今日专注",
                      size: 14.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warmOrange,
                    ),
                  ),
                  Wrap(
                    runSpacing: 20.0,
                    spacing: 30.0,
                    alignment: WrapAlignment.spaceBetween,
                    children: widget.studyDetails.aboutTodayData.map((model) {
                      return SizedBox(
                        child: CustomCard(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  model.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.warmOrange,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Gen-light',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  model.data.values.first,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.warmOrange,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 3),

////////////////// 第三个container ”数据统计“以及"日历" ，分成左右侧两个部分//////////////////
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              //height: 450,
              child: Row(
                children: [
                  // 左侧部分
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: AppColors.deppBeige,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          // Text(
                          //   "专注时长分析",
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                          MyPieChart(
                            //selectedDate: selectedDate,
                            selectedDate: selectedDate,
                            data: selectedDateData,
                          ),
                          //SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                          // Container(
                          //   padding: EdgeInsets.all(defaultPadding),
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //         width: 2,
                          //         color: AppColors.secondary.withOpacity(0.15)),
                          //     borderRadius: const BorderRadius.all(
                          //         Radius.circular(defaultPadding)),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3),
                  // 右侧部分
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      //位于lib/StatisticsPage/component/calendarWidget.dart中
                      child: CalendarWidget(
                          onDateSelected: (DateTime date) {
                            setState(() {
                              selectedDate = date;
                              selectedDateData =
                                  analyzeData(records, selectedDate);
                              print('Selected Date: $selectedDate');
                              print('Selected Date Data: $selectedDateData');
                            });
                          },
                          events: _eventDates),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
