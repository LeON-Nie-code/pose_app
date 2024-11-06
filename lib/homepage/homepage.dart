

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/homepage/component/appBarActionItems.dart';
import 'package:pose_app/homepage/component/header.dart';
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
                              Container(
                                constraints: BoxConstraints(minWidth: 150.0),
                                padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0, right: 40.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: AppColors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: SizeConfig.blockSizeVertical! * 2,),
                                    PrimaryText(text: "专注排行榜", fontWeight: FontWeight.w700, size: 18.0,),
                                    PrimaryText(text: "1名/20", color: AppColors.secondary,size: 16.0,)
                                  ],
                                ),

                              ),
                              Container(
                                constraints: BoxConstraints(minWidth: 150.0),
                                padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0, right: 40.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: AppColors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: SizeConfig.blockSizeVertical! * 2,),
                                    PrimaryText(text: "专注排行榜", fontWeight: FontWeight.w700, size: 18.0,),
                                    PrimaryText(text: "1名/20", color: AppColors.secondary,size: 16.0,)
                                  ],
                                ),

                              ),
                              Container(
                                constraints: BoxConstraints(minWidth: 150.0),
                                padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0, right: 40.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: AppColors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: SizeConfig.blockSizeVertical! * 2,),
                                    PrimaryText(text: "专注排行榜", fontWeight: FontWeight.w700, size: 18.0,),
                                    PrimaryText(text: "1名/20", color: AppColors.secondary,size: 16.0,)
                                  ],
                                ),

                              ),

                            
                              
                            ],
                          ),
                        ),

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




