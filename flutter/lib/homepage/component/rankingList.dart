import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';


class rankingList extends StatelessWidget {
  final String? icon;
  final String? label;
  final String? amount;
  final Widget dialogContent;

  const rankingList({
    this.icon, 
    this.label, 
    this.amount,
    required this.dialogContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 160.0,
        minWidth: 150.0),
      padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 60.0, right: 50.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0,3),
          ),
          ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [ 
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(icon!, width: 35.0,),
              IconButton(
              onPressed:(){
                showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SizedBox(
                    width: 900,
                    height: 700,
                    child: dialogContent,
                  ),
                );
              },
            );
              } , 
              icon: Icon(Icons.more_horiz, color: Colors.grey,),
              iconSize: 20,
              ),
            ],
          ),
          
          SizedBox(height: SizeConfig.blockSizeVertical! * 2,),
          PrimaryText(text: label!, fontWeight: FontWeight.w700, size: 17.0,),
          PrimaryText(text: amount!, color: AppColors.secondary,size: 16.0,),
          
        ],
      ),
    
    );
  }
}


