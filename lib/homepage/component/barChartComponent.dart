//数据目前只是一个例子

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pose_app/style/colors.dart';


class BarChartComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceBetween,
        axisTitleData: FlAxisTitleData(leftTitle: AxisTitle(reservedSize: 20)),
        gridData: FlGridData(drawHorizontalLine: true, horizontalInterval: 3),
        titlesData: FlTitlesData(leftTitles: SideTitles(reservedSize: 30, 
        getTextStyles: (value)=>const TextStyle(color: Colors.grey, fontSize: 12),showTitles: true, getTitles: (value){
          if(value == 0){
            return '0';
          } else if (value == 3){
            return '3h';
          } else if (value ==6){
            return '6h';
          } else if (value ==9){
            return '9h';
          } else{
            return '';
          }
        })),
        barGroups: [
          //目前只是例子
          BarChartGroupData(x: 0,
          barRods: [
            BarChartRodData(y: 1, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),

            BarChartRodData(y: 5, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),

            BarChartRodData(y: 3, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),

            BarChartRodData(y: 8, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),
            
            BarChartRodData(y: 7, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),

            BarChartRodData(y: 8, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),

            BarChartRodData(y: 2, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),

            BarChartRodData(y: 9, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),

            BarChartRodData(y: 6, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),

            BarChartRodData(y: 1, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),
          ],),
        ]
      ),
      swapAnimationDuration: Duration(microseconds: 150),
      swapAnimationCurve: Curves.linear,
    );
  }
}
