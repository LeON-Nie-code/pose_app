
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';


class RecordListOfUsers extends StatelessWidget {
  final String? icon;
  final String? label;
  final String? amount;
  
  const RecordListOfUsers({
    @required this.icon, this.label, this.amount
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0, right: 20.0),
      visualDensity: VisualDensity.standard,
      leading: Container(
        width: 50.0,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SvgPicture.asset(icon!, width: 20.0,),
      ),
      title: PrimaryText(text: label!, size: 14.0, fontWeight: FontWeight.w500,),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PrimaryText(text: 'Successfully', size: 12.0, color: AppColors.secondary,),
          PrimaryText(text: amount!, size: 16.0, color: AppColors.secondary,
          fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}
