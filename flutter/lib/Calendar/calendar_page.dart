// lib/Calendar/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:pose_app/Calendar/component/todoList.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';


class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(height: 18),
          
          Todolist(), 
        ],
      ),
    );
  }
}