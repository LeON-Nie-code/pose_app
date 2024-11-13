import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/homepage/component/VideoDialog.dart';
import 'package:pose_app/homepage/component/recordListOfUsers.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/data.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';

class StartToStudyDetail extends StatelessWidget {
  const StartToStudyDetail({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 15, // 按钮上方的间距
        ),

        // 按钮组件
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 20),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return VideoDialog();
              },
            );
          },
          child: Text("开始"),
        ),

        // 按钮下方的间距
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 15, // 调整此值来增加下方的间距
        ),

        // 个人专注部分的记录列表
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryText(
              text: '个人专注记录',
              size: 18,
              fontWeight: FontWeight.w800,
            ),
            PrimaryText(
              text: '02 Mar 20xx（例子）',
              size: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ],
        ),

        SizedBox(
          height: SizeConfig.blockSizeVertical! * 2,
        ),

        Column(
          children: List.generate(
            recentActivities.length,
            (index) => RecordListOfUsers(
              icon: recentActivities[index]["icon"],
              label: recentActivities[index]["label"],
              amount: recentActivities[index]["amount"],
            ),
          ),
        ),

        // 集体专注记录
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 5,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryText(
              text: '集体专注记录',
              size: 18,
              fontWeight: FontWeight.w800,
            ),
            PrimaryText(
              text: '02 Mar 2021（例子）',
              size: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ],
        ),

        SizedBox(
          height: SizeConfig.blockSizeVertical! * 2,
        ),

        Column(
          children: List.generate(
            upcomingPayments.length,
            (index) => RecordListOfUsers(
              icon: upcomingPayments[index]["icon"],
              label: upcomingPayments[index]["label"],
              amount: upcomingPayments[index]["amount"],
            ),
          ),
        ),
      ],
    );
  }
}
