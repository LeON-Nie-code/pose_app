import 'package:flutter/material.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';
import 'package:intl/intl.dart';

class Header extends StatelessWidget {
  final String username;

  const Header({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('yyyy/MM/dd').format(DateTime.now());
    return Row(
      children: [
        SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 动态显示用户名
              PrimaryText(
                text: '欢迎！$username',
                size: 30.0,
                fontWeight: FontWeight.w800,
              ),
              PrimaryText(
                text: todayDate,
                size: 16.0,
                color: AppColors.secondary,
              ),
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
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.black,
              ),
              hintText: 'Search',
              hintStyle: TextStyle(color: AppColors.secondary, fontSize: 14.0),
            ),
          ),
        ),
      ],
    );
  }
}
