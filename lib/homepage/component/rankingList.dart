import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';


class rankingList extends StatelessWidget {
  final String? icon;
  final String? label;
  final String? amount;
  const rankingList({
    this.icon, this.label, this.amount
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 150.0),
      padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0, right: 40.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
          SvgPicture.asset(icon!, width: 35.0,),
          SizedBox(height: SizeConfig.blockSizeVertical! * 2,),
          PrimaryText(text: label!, fontWeight: FontWeight.w700, size: 18.0,),
          PrimaryText(text: amount!, color: AppColors.secondary,size: 16.0,)
        ],
      ),
    
    );
  }
}


