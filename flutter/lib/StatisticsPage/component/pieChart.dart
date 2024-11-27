//piechart数据部分，在考虑换成实现的graph（因为piechart看起来好看，但是我觉得到时候很能统计上去，，）

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pose_app/style/colors.dart';

class MyPieChart extends StatelessWidget {
  const MyPieChart({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: pieChartSectionDatas,
            ),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> pieChartSectionDatas = [
  PieChartSectionData(
    value: 25,
    color: AppColors.pinkpg,
    showTitle: false,
    radius: 25,
  ),
  PieChartSectionData(
    value: 20,
    color: AppColors.secondary,
    showTitle: false,
    radius: 25,
  ),
  PieChartSectionData(
    value: 15,
    color: AppColors.warmOrange,
    showTitle: false,
    radius: 25,
  ),
  PieChartSectionData(
    value: 15,
    color: AppColors.bluegrey,
    showTitle: false,
    radius: 25,
  ),
  PieChartSectionData(
    value: 15,
    color: AppColors.iconGray.withOpacity(0.1),
    showTitle: false,
    radius: 25,
  ),
];
