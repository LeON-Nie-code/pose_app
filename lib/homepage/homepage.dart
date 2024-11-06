

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




