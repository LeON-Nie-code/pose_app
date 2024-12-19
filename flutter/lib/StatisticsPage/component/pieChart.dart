import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';
import 'package:intl/intl.dart';

class MyPieChart extends StatelessWidget {
  final DateTime? selectedDate; // 新增选中日期参数
  final Map<String, dynamic> data;

  const MyPieChart({
    Key? key,
    this.selectedDate,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取选中日期的时长
    double targetDateDuration = data['targetDateDuration'] ?? 0.0;
    double totalDuration = data['totalDuration'] ?? 0.0;

    // 计算剩余时长
    double remainingDuration = (totalDuration - targetDateDuration).clamp(0.0, double.infinity);

    // 构建饼图数据
    List<PieChartSectionData> pieChartSections = [
      // 选中日期的总时长部分
      PieChartSectionData(
        value: targetDateDuration,
        color: AppColors.pinkpg,
        showTitle: false,
        radius: 25,
      ),
      // 剩余部分
      PieChartSectionData(
        value: remainingDuration,
        color: AppColors.iconGray.withOpacity(0.1),
        showTitle: false,
        radius: 25,
      ),
    ];

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(defaultPadding * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Text(
                  '数据专注分析',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            // 选中日期显示
            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat("yyyy年MM月dd日").format(selectedDate!),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            SizedBox(height: 15),
            // 饼图及中心文字
            Stack(
              alignment: Alignment.center,
              children: [
                // 饼图
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 70,
                      startDegreeOffset: -90,
                      sections: pieChartSections,
                    ),
                  ),
                ),
                // 中心的总时长
                if (selectedDate != null)
                  Text(
                    '${(targetDateDuration / 60).toStringAsFixed(2)} 分钟',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
