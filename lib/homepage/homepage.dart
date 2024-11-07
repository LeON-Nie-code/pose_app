

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/homepage/component/appBarActionItems.dart';
import 'package:pose_app/homepage/component/header.dart';
import 'package:pose_app/homepage/component/rankingList.dart';
import 'package:pose_app/homepage/component/sidemenu.dart';
import 'package:pose_app/homepage/component/startToStudyDetail.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';

class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    SizeConfig().init(context);
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //最左侧bar,详细的设计位于lib/component/sidemenu.dart中
            Expanded(
              flex: 1,
              child: SideMenu(),
            ),      
            //中间的内容
            Expanded(
              flex: 10,
              child: Container(
                width: double.infinity,
                height: SizeConfig.screenHeight,
                color: AppColors.beige,
                child: SingleChildScrollView(
                  padding: 
                    EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                    child: Column(
                      children: [
                        //中间框架的的开头标题以及探索功能位于lib/component/header.dart
                        Header(),

                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 4
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth,
                          child: Wrap(
                            runSpacing: 20.0,
                            spacing: 20.0,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              //详细的位于lib/homepage/component/rankingList.dart中
                              //专注排行榜框架，
                              rankingList(

                                icon:'assets/icons/ranking.svg',
                                label: '专注排行榜',
                                amount: '1名/20',
                              ),
                              //在线好友
                              rankingList(

                                icon:'assets/icons/online.svg',
                                label: '好友在线',
                                amount: '用户1',
                              ),
                              
                              //今日代办
                              rankingList(

                                icon:'assets/icons/todolist.svg',
                                label: '今日代办',
                                amount: '任务1',
                                
                              ),
                              
                              
                            ],
                          ),
                        ),
                        //”数据统计“标题 
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 4,

                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PrimaryText(
                                  text: 'xx月xx日 - xx月xx',
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

                      
                            
                          ],
                        )

                      ],
                    ),

                ),
                
              ),
            ),
            //最右侧，开始专注的地方
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                height: SizeConfig.screenHeight,
                color: AppColors.deppBeige,
                padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                  child: Column(
                    children: [
                      //右侧的container中的上方设计位于lib/component/appBarActionItems.dart中
                      AppBarActionItems(),
                      //右侧的开始专注部分，位于lib/component/startToStudyDetail.dart中
                      StartToStudyDetail(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
    );
  }
}

