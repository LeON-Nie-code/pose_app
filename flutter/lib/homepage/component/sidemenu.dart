import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback onNavigateToHome;
  final VoidCallback onNavigateToStatistics;
  final VoidCallback onNavigateToCalendar;
  final VoidCallback onNavigateToCommunication;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onNavigateToSignOut;
  final String username;

  const SideMenu({
    Key? key,
    required this.onNavigateToHome,
    required this.onNavigateToStatistics,
    required this.onNavigateToCalendar,
    required this.onNavigateToCommunication,
    required this.onNavigateToSettings,
    required this.onNavigateToSignOut,
    required this.username,
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
                  child: GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      // 获取点击位置并显示对话框
                      _showPopupDialog(context, details.globalPosition);
                    },
                    child: SvgPicture.asset('assets/icons/User_example.svg'),
                  ),
                ),
              ),
              // 主页按钮
              IconButton(
                onPressed: onNavigateToHome,
                icon: SvgPicture.asset('assets/icons/Home.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              // 日历按钮
              IconButton(
                onPressed: onNavigateToCalendar,
                icon: SvgPicture.asset('assets/icons/calendar.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              // 朋友圈按钮
              IconButton(
                onPressed: onNavigateToCommunication,
                icon: SvgPicture.asset('assets/icons/Chat.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              // 统计按钮
              IconButton(
                onPressed: onNavigateToStatistics,
                icon: SvgPicture.asset('assets/icons/pie-chart.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              // 设置按钮
              IconButton(
                onPressed: onNavigateToSettings,
                icon: SvgPicture.asset('assets/icons/Setting.svg', color: AppColors.iconGray),
                iconSize: 20,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              // 退出按钮
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

  void _showPopupDialog(BuildContext context, Offset position) {
    // 计算弹窗位置
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: position.dx + 40, // 头像右侧
              top: position.dy, // 对齐头像垂直位置
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 250,
                  height: 150,  
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10,),
                      Text(
                        "用户名: $username",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.beige,
                          ),
                          onPressed: () {
                            // 执行退出逻辑
                            Navigator.of(context).pop();
                            onNavigateToSignOut();
                          },
                          child: Text(
                            "退出账号",
                            style: TextStyle(
                              color: AppColors.warmOrange,
                            ),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
