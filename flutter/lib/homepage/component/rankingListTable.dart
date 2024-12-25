import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pose_app/config/config.dart';

class RankingListTable extends StatefulWidget {
  const RankingListTable({super.key});

  @override
  _RankingListTableState createState() => _RankingListTableState();
}

class _RankingListTableState extends State<RankingListTable> {
  List<dynamic> rankingData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRankingData();
  }

  Future<void> fetchRankingData() async {
    try {
      // 初始化 SharedPreferences 并获取 accessToken
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        throw Exception("Access token is missing");
      }

      // 设置 Dio 实例
      Dio dio = Dio();
      final String url = '${Config.baseUrl}/users/top-durations'; // 添加分页参数

      // 发起请求
      // final response = await dio.get('${Config.baseUrl}/users/top-durations');

      print("accessToken: $accessToken");

      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken', // 携带 JWT token
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          rankingData = response.data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  DataRow rankingListDataRow(dynamic fileInfo) {
    String formatDuration(double durationInSeconds) {
      if (durationInSeconds < 60) {
        return '${durationInSeconds.toStringAsFixed(0)}s'; // 小于 60 秒，单位为秒
      } else if (durationInSeconds < 3600) {
        double minutes = durationInSeconds / 60;
        return '${minutes.toStringAsFixed(1)}m'; // 小于 1 小时，单位为分钟
      } else {
        double hours = durationInSeconds / 3600;
        return '${hours.toStringAsFixed(2)}h'; // 1 小时或以上，单位为小时
      }
    }

    return DataRow(
      cells: [
        DataCell(Text(fileInfo['rank'].toString())),
        DataCell(Text(fileInfo['username'] ?? 'N/A')),
        DataCell(Text(formatDuration(fileInfo['total_duration']))), // 使用转换后的时间
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.beige,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 限制最大高度
          maxWidth: 600, // 限制宽度
        ),
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryText(
                      text: '排行榜',
                      size: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                    PrimaryText(
                      text: '20xx/xx/xx',
                      size: 16.0,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              DataTable(
                                columnSpacing: defaultPadding,
                                columns: [
                                  DataColumn(label: Text('排名')),
                                  DataColumn(label: Text('用户名')),
                                  DataColumn(label: Text('总时间')),
                                ],
                                rows: rankingData.isEmpty
                                    ? []
                                    : List.generate(
                                        rankingData.length,
                                        (index) => rankingListDataRow(
                                            rankingData[index]),
                                      ),
                              ),
                            ],
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
