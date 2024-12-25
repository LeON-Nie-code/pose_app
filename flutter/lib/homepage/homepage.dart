import 'package:flutter/material.dart';
import 'package:pose_app/homepage/component/appBarActionItems.dart';
import 'package:pose_app/homepage/component/barChartComponent.dart';
import 'package:pose_app/homepage/component/header.dart';
import 'package:pose_app/homepage/component/rankingList.dart';
import 'package:pose_app/homepage/component/rankingListTable.dart';
import 'package:pose_app/homepage/component/sidemenu.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/homepage/component/startToStudyDetail.dart';
import 'package:pose_app/homepage/component/todayTodoDialog.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/StatisticsPage/statistics_page.dart';
import 'package:pose_app/Calendar/calendar_page.dart';
import 'package:pose_app/Community/communication_page.dart';
import 'package:pose_app/Setting/setting_page.dart';
import 'package:pose_app/SignOut/signout_page.dart';
import 'package:pose_app/style/style.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Flex values for the second and third sections
  int _leftFlex = 10;
  int _rightFlex = 6;

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;

      // Adjust layout for specific pages
      if (index == 0) {
        _leftFlex = 10;
        _rightFlex = 6;
      } else {
        _leftFlex = 16;
        _rightFlex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime sevenDaysAgo = today.subtract(Duration(days: 7));
    String dateRange =
        "${DateFormat('MM月dd日').format(sevenDaysAgo)} - ${DateFormat('MM月dd日').format(today)}";

    SizeConfig().init(context);
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side menu
            Expanded(
              flex: 1,
              child: SideMenu(
                username: widget.username,
                onNavigateToHome: () => _navigateToPage(0),
                onNavigateToStatistics: () => _navigateToPage(1),
                onNavigateToCalendar: () => _navigateToPage(2),
                onNavigateToCommunication: () => _navigateToPage(3),
                onNavigateToSettings: () => _navigateToPage(4),
                onNavigateToSignOut: () => _navigateToPage(5),
              ),
            ),
            // Middle section
            Expanded(
              flex: _leftFlex,
              child: Container(
                width: double.infinity,
                height: SizeConfig.screenHeight,
                color: AppColors.beige,
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 30.0),
                      child: Column(
                        children: [
                          Header(username: widget.username),
                          SizedBox(height: SizeConfig.blockSizeVertical! * 4),
                          SizedBox(
                            width: SizeConfig.screenWidth,
                            child: Wrap(
                              runSpacing: 20.0,
                              spacing: 20.0,
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                rankingList(
                                  icon: 'assets/icons/ranking.svg',
                                  label: '专注排行榜',
                                  amount: '1名/20',
                                  dialogContent: RankingListTable(),
                                ),
                                rankingList(
                                  icon: 'assets/icons/online.svg',
                                  label: '好友在线',
                                  amount: '用户1',
                                  dialogContent: Center(
                                    child: Text(
                                      '是否好友在线',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                rankingList(
                                  icon: 'assets/icons/todolist.svg',
                                  label: '今日代办',
                                  amount: '点击查看',
                                  dialogContent: TodayTodoDialog(),
                                  //Center(
                                  //   child: Text(
                                  //     'Todo列表',
                                  //     style: TextStyle(fontSize: 18),
                                  //   ),
                                  // ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical! * 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PrimaryText(
                                    text: dateRange,
                                    size: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondary,
                                  ),
                                  PrimaryText(
                                    text: '数据统计',
                                    size: 30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ],
                              ),
                              PrimaryText(
                                text: 'Past 7 Days',
                                size: 16,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical! * 3),
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
                            height: 300,
                            child: BarChartComponent(),
                          ),
                        ],
                      ),
                    ),
                    StatisticsPage(),
                    CalendarPage(),
                    CommunicationPage(),
                    SettingPage(
                      username: widget.username,
                    ),
                    SignOutPage(),
                  ],
                ),
              ),
            ),
            // Right section
            if (_rightFlex > 0)
              Expanded(
                flex: _rightFlex,
                child: Container(
                  width: double.infinity,
                  height: SizeConfig.screenHeight,
                  color: AppColors.deppBeige,
                  padding:
                      EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                    child: Column(
                      children: [
                        AppBarActionItems(),
                        StartToStudyDetail(),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
