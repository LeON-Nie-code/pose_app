import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pose_app/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pose_app/config/config.dart';

class BarChartComponent extends StatefulWidget {
  @override
  _BarChartComponentState createState() => _BarChartComponentState();
}

class _BarChartComponentState extends State<BarChartComponent> {
  List<dynamic> records = []; // 存储从后端获取的记录数据
  List<double> durations = List.filled(7, 0.0); // 用于存储过去 7 天的总时长

  @override
  void initState() {
    super.initState();
    fetchRecordsAndCalculateDurations();
  }

  Future<void> fetchRecordsAndCalculateDurations() async {
    try {
      // 从后端获取记录
      final prefs = await SharedPreferences.getInstance();
      final storedAccessToken = prefs.getString('accessToken');
      if (storedAccessToken == null || storedAccessToken.isEmpty) {
        throw Exception('Access Token not found');
      }
      final Dio dio = Dio();
      Response response = await dio.get(
        '${Config.baseUrl}/records',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $storedAccessToken',
        }),
      );
      records = response.data;

      // 计算过去 7 天的总时长
      final today = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final targetDate = today.subtract(Duration(days: 6 - i));
        durations[i] = calculateTotalDurationForDate(targetDate);
      }

      setState(() {});
    } catch (e) {
      print('Error fetching or calculating durations: $e');
    }
  }

  double calculateTotalDurationForDate(DateTime date) {
    double totalDuration = 0.0;
    final dateFormatter = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");

    for (var record in records) {
      try {
        final recordDate = dateFormatter.parse(record['created_at']);
        if (isSameDay(recordDate, date)) {
          totalDuration += record['duration'];
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    return totalDuration / 60; // 转换为分钟
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final List<String> last7DaysLabels = List.generate(
      7,
      (index) =>
          DateFormat('MM/dd').format(today.subtract(Duration(days: 6 - index))),
    );

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceBetween,
        axisTitleData: FlAxisTitleData(leftTitle: AxisTitle(reservedSize: 20)),
        gridData: FlGridData(drawHorizontalLine: true, horizontalInterval: 15),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            reservedSize: 30,
            getTextStyles: (value) =>
                const TextStyle(color: Colors.grey, fontSize: 12),
            showTitles: true,
            getTitles: (value) {
              if (value == 0) {
                return '0';
              } else if (value == 30) {
                return '30min';
              } else if (value == 60) {
                return '60min';
              } else if (value == 90) {
                return '90min';
              } else if (value == 120) {
                return '120min';
              } else if (value == 150) {
                return '120min';
              } else if (value == 180) {
                return '120min';
              } else if (value == 210) {
                return '120min';
              } else {
                return '';
              }
            },
          ),
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) =>
                const TextStyle(color: Colors.grey, fontSize: 12),
            getTitles: (value) {
              if (value >= 0 && value < last7DaysLabels.length) {
                return last7DaysLabels[value.toInt()];
              } else {
                return '';
              }
            },
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 10,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.y.toStringAsFixed(1)} min',
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                y: durations[index],
                colors: [
                  index == 6 ? AppColors.pinkpg : AppColors.warmOrange
                ], // 今日为特殊颜色
                borderRadius: BorderRadius.circular(0),
                width: 40,
                backDrawRodData: BackgroundBarChartRodData(
                  y: 90,
                  show: true,
                  colors: [AppColors.barcolor],
                ),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: Duration(microseconds: 150),
      swapAnimationCurve: Curves.linear,
    );
  }
}
