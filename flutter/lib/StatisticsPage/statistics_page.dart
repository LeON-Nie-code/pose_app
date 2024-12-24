// import 'package:flutter/material.dart';
// import 'package:pose_app/StatisticsPage/component/dataDtailsCards.dart';
// import 'package:pose_app/config/size_config.dart';
// import 'package:pose_app/homepage/component/header.dart';
// import 'package:pose_app/statistic_data.dart';
// import 'package:pose_app/style/colors.dart';

// class StatisticsPage extends StatelessWidget {
//   const StatisticsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     // 创建StudyDetails的实例
//     final studyDetails = StudyDetails(); // 确保StudyDetails类已正确导入

//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(horizontal: 16.0),
//       child: Column(
//         children: [
//           SizedBox(height: 18),
//           //位于lib/StatisticsPage/component/dataDtailsCards

//           DataDetailsCard(studyDetails: studyDetails),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pose_app/StatisticsPage/component/dataDtailsCards.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/statistic_data.dart';
import 'package:pose_app/style/colors.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<StudyDetails> _studyDetailsFuture;

  @override
  void initState() {
    super.initState();
    _studyDetailsFuture = fetchStudyDetails();
  }

  Future<StudyDetails> fetchStudyDetails() async {
    List<dynamic> records = await getUserRecords();
    StudyDetails details = StudyDetails();
    analyzeAndUpdateDetails(records, details);
    return details;
  }

Future<List<dynamic>> getUserRecords() async {
  final prefs = await SharedPreferences.getInstance();
  final storedAccessToken = prefs.getString('accessToken');
  if (storedAccessToken == null || storedAccessToken.isEmpty) {
    throw Exception('Access Token not found');
  }

  Dio dio = Dio();
  Response response = await dio.get(
    'http://8.217.68.60/records',
    options: Options(headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $storedAccessToken',
    }),
  );

  return response.data;
}


  void analyzeAndUpdateDetails(List<dynamic> records, StudyDetails details) {
    Map<String, dynamic> data = analyzeData(records, null);
    details.aboutTotalData[0] = StudyDataModel(
      title: "次数",
      data: {"value": data['totalRecords'].toString()},
    );
    details.aboutTotalData[1] = StudyDataModel(
      title: "时长",
      data: {"totalHour": (data['totalDuration'] / 60).toStringAsFixed(2)},
    );
  }

  Map<String, dynamic> analyzeData(
      List<dynamic> records, DateTime? targetDate) {
    Map<String, dynamic> result = {
      'totalRecords': records.length,
      'totalDuration': records.fold(0.0, (sum, record) => sum + record['duration']),
    };
    return result;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return FutureBuilder<StudyDetails>(
      future: _studyDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("加载失败"));
        } else if (snapshot.hasData) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 18),
                DataDetailsCard(studyDetails: snapshot.data!),
              ],
            ),
          );
        } else {
          return Center(child: Text("暂无数据"));
        }
      },
    );
  }
}
