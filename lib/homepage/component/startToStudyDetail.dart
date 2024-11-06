import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
        SizedBox(height: SizeConfig.blockSizeVertical!*5,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1.0),
            boxShadow: [BoxShadow(
              color: AppColors.iconGray,
              blurRadius: 13.0,
              offset: const Offset(3.0, 3.0)
            )]
          ),
          child: Image.asset('assets/icons/startToStudy.jpg'),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical!*5,
          ),
        
        //个人专注部分的记录列表
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryText(text: '个人专注记录', size: 18, fontWeight: FontWeight.w800,),
            PrimaryText(text: '02 Mar 20xx（例子）', size: 14, fontWeight: FontWeight.w400, color: AppColors.secondary,),
          ],
        ),
        //列表的详细内容位于lib/component/RecordListOfUsers(.dart中
        SizedBox(
          height: SizeConfig.blockSizeVertical!*2,
          ),
          Column(
            children: List.generate(recentActivities.length, (index)=>RecordListOfUsers(
              icon:recentActivities[index]["icon"],
              label:recentActivities[index]["label"],
              amount:recentActivities[index]["amount"],
              
            ),),
          ),

          //集体专注
        SizedBox(
          height: SizeConfig.blockSizeVertical!*5,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryText(text: '集体专注记录', size: 18, fontWeight: FontWeight.w800,),
            PrimaryText(text: '02 Mar 2021（例子）', size: 14, fontWeight: FontWeight.w400, color: AppColors.secondary,),
          ],
        ),
      
        SizedBox(
          height: SizeConfig.blockSizeVertical!*2,
          ),
          Column(
            children: List.generate(upcomingPayments.length, (index)=>RecordListOfUsers(
              icon:upcomingPayments[index]["icon"],
              label:upcomingPayments[index]["label"],
              amount:upcomingPayments[index]["amount"],
              
            ),),
          ),


      ],
    );
  }
}
