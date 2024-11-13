
import 'package:flutter/material.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';


class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //暂时定义为text中，等后端的data拿过来的话再改一改
              PrimaryText(text: '欢迎！（用户名）',size: 30.0,fontWeight: FontWeight.w800,),
              PrimaryText(text: '20xx/xx/xx',size: 16.0,color: AppColors.secondary,)
            ],
          ),
        ),
    
        Spacer(
          flex: 1,
          ),
        Expanded(
          flex: 1,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              contentPadding: EdgeInsets.only(left: 40.0, right: 5.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: AppColors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: AppColors.white),
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.black,),
              hintText: 'Search',
              hintStyle: TextStyle(color: AppColors.secondary, fontSize: 14.0),
      
            ),
          ),
          ),
      ],
    );
  }
}