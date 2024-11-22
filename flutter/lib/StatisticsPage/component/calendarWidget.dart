import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pose_app/style/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {

  DateTime _focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${DateFormat("MM,yyyy").format(_focusedDay)}", 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 20,
              ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap:(){
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month-1);
                      });
                    },
                    child: Icon(Icons.chevron_left, color: AppColors.black,),
                  ),
                  InkWell(
                    onTap:(){
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month+1);
                      });
                    },
                    child: Icon(Icons.chevron_right, color: AppColors.black,),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10,),
          TableCalendar(
            focusedDay: _focusedDay, 
            firstDay: DateTime.utc(2010), 
            lastDay:  DateTime.utc(2040),
            headerVisible: false,
            onFormatChanged:(result){},
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale){
                return DateFormat("EEE").format(date).toUpperCase();
              },
              weekendStyle: TextStyle(fontWeight: FontWeight.bold),
              weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPageChanged: (day){
              _focusedDay = day;
              setState(() {
                
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.warmOrange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.warmOrange,
                shape: BoxShape.circle,
              ),
            ),
            
            ),
        ],
      ),

    );
  }
}