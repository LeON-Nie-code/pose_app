import 'package:flutter/material.dart';
import 'package:pose_app/StatisticsPage/component/dataDtailsCards.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/homepage/component/header.dart';
import 'package:pose_app/style/colors.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(height: 18),
          //位于lib/StatisticsPage/component/dataDtailsCards
          DataDetailsCard(), 
        ],
      ),
    );
  }
}
