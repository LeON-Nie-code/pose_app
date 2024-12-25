import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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
    double postureAbnormalDuration = data['postureAbnormalDuration'] ?? 0.0;

    // 如果 `totalDuration` 为 0，设置默认值，避免饼图报错
    if (totalDuration == 0) {
      totalDuration = 1;
      targetDateDuration = 0; // 防止 0 的部分渲染
    }

    // 计算剩余时长
    double remainingDuration =
        (totalDuration - targetDateDuration - postureAbnormalDuration)
            .clamp(0.0, double.infinity);

    // 构建饼图数据
    List<PieChartSectionData> pieChartSections = [
      if (targetDateDuration > 0) // 专注时长部分
        PieChartSectionData(
          value: targetDateDuration,
          color: AppColors.pinkpg,
          showTitle: false,
          radius: 25,
        ),
      if (postureAbnormalDuration > 0) // 坐姿异常部分
        PieChartSectionData(
          value: postureAbnormalDuration,
          color: AppColors.bluegrey,
          showTitle: false,
          radius: 25,
        ),
      if (remainingDuration > 0) // 其他时长部分
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
                    fontFamily: 'Gen-light',
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
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.pinkpg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(width: 10),
                const Text(
                  '专注时长',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    fontFamily: 'Gen-light',
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.bluegrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(width: 10),
                const Text(
                  '坐姿异常',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    fontFamily: 'Gen-light',
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.iconGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(width: 10),
                const Text(
                  '其他',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    fontFamily: 'Gen-light',
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '总时长',
                      style: GoogleFonts.notoSans(
                        textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.pinkpg.withOpacity(0.7)),
                      ),
                    ),
                    Text(
                      '${(targetDateDuration / 60).toStringAsFixed(2)} 分钟',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.pinkpg.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '坐姿异常',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bluegrey.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${(postureAbnormalDuration / 60).toStringAsFixed(2)} 分钟',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bluegrey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
