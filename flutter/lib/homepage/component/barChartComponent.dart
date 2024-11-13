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
        }),
        bottomTitles: SideTitles(
          showTitles: true, getTextStyles: (value) => const TextStyle(
            color: Colors.grey, fontSize: 12
          ),getTitles: (value) {
            
            if(value == 0){
            return 'MON';
          } else if (value == 1){
            return 'TUE';
          }else if (value == 2){
            return 'WED';
          }else if (value == 3){
            return 'THU';
          }else if (value == 4){
            return 'FRI';
          }else if (value == 5){
            return 'SAT';
          }else if (value == 6){
            return 'SUN';
          }else{
            return'';
          }
          },

        )
        ),
        barGroups: [
          //目前只是例子
          BarChartGroupData(x: 0,
          barRods: [
            BarChartRodData(y: 1, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),
          ],),

          BarChartGroupData(x: 1,
          barRods: [
            BarChartRodData(y: 4, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),
          ],),

          BarChartGroupData(x: 2,
          barRods: [
            BarChartRodData(y: 5, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),
          ],),

          BarChartGroupData(x: 3,
          barRods: [
            BarChartRodData(y: 7, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),
          ],),

          BarChartGroupData(x: 4,
          barRods: [
            BarChartRodData(y: 1, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),
          ],),

          BarChartGroupData(x: 5,
          barRods: [
            BarChartRodData(y: 9, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),
          ],),

          BarChartGroupData(x: 6,
          barRods: [
            BarChartRodData(y: 2, colors: [AppColors.warmOrange], borderRadius: BorderRadius.circular(0), 
            width: 40, backDrawRodData: BackgroundBarChartRodData(y:9, show: true, colors: [AppColors.barcolor]),),
          ],),

          
          
        ]
      ),
      swapAnimationDuration: Duration(microseconds: 150),
      swapAnimationCurve: Curves.linear,
    );
  }
}



