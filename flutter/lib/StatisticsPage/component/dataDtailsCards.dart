import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pose_app/StatisticsPage/component/calendarWidget.dart';
import 'package:pose_app/StatisticsPage/component/custom_card.dart';
import 'package:pose_app/statistic_data.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/StatisticsPage/component/pieChart.dart';
import 'package:pose_app/style/style.dart';

class DataDetailsCard extends StatefulWidget {
  final StudyDetails studyDetails; // 将成员变量作为构造函数参数传递

  DataDetailsCard({Key? key, required this.studyDetails}) : super(key: key);

  @override
  _DataDetailsCardState createState() => _DataDetailsCardState();
}

class _DataDetailsCardState extends State<DataDetailsCard> {
  // 在这里定义需要在状态中管理的变量

  @override
  void initState() {
    super.initState();
    // 初始化状态
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // 初始化屏幕尺寸配置
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
                      text: '今天：xx月xx日',
                      size: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ],
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
                                    fontSize: 13,
                                    color: AppColors.warmOrange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  model.data.values.first,
                                  style: const TextStyle(
                                    fontSize: 15,
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
                                    fontSize: 13,
                                    color: AppColors.warmOrange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  model.data.values.first,
                                  style: const TextStyle(
                                    fontSize: 15,
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
              height: 400,
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
                          Text(
                            "专注时长分析",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                          MyPieChart(),
                          SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                          Container(
                            padding: EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2,
                                  color: AppColors.secondary.withOpacity(0.15)),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(defaultPadding)),
                            ),
                          ),
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
                      child: CalendarWidget(),
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
