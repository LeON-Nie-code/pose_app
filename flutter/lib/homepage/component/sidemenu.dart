import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback onNavigateToHome;
  final VoidCallback onNavigateToStatistics;
  final VoidCallback onNavigateToCalendar;
  final VoidCallback onNavigateToCommunication;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onNavigateToSignOut;

  const SideMenu({
    Key? key,
    required this.onNavigateToHome,
    required this.onNavigateToStatistics,
    required this.onNavigateToCalendar,
    required this.onNavigateToCommunication,
    required this.onNavigateToSettings,
    required this.onNavigateToSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        width: double.infinity,
        height: SizeConfig.screenHeight,
        color: AppColors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: SvgPicture.asset('assets/icons/User_example.svg'),
                ),
              ),
              //主页按钮
              IconButton(
                onPressed: onNavigateToHome,
                icon: SvgPicture.asset('assets/icons/Home.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              //日历按钮
              IconButton(
                onPressed: onNavigateToCalendar,
                icon: SvgPicture.asset('assets/icons/calendar.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              //朋友圈（广场）按钮
              IconButton(
                onPressed: onNavigateToCommunication,
                icon: SvgPicture.asset('assets/icons/Chat.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              //统计按钮
              IconButton(
                onPressed: onNavigateToStatistics,
                icon: SvgPicture.asset('assets/icons/pie-chart.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              //设置按钮
              IconButton(
                onPressed: onNavigateToSettings,
                icon: SvgPicture.asset('assets/icons/Setting.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              //退出按钮
              IconButton(
                onPressed: onNavigateToSignOut,
                icon: SvgPicture.asset('assets/icons/signout.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
