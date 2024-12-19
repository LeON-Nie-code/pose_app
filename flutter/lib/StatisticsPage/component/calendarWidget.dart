import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pose_app/style/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected; // 回调函数，用于通知主页面选中的日期

  CalendarWidget({Key? key, required this.onDateSelected}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // 用于存储当前选中的日期

  // 模拟定义一个简单的事件模型（到时候要断成有记录的日期）
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2024, 12, 22): ["Event 1"],
    DateTime.utc(2024, 12, 12): ["Event 2"],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          // 顶部月份和左右切换按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${DateFormat("MMMM, yyyy").format(_focusedDay)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        );
                      });
                    },
                    child: Icon(
                      Icons.chevron_left,
                      color: AppColors.black,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        );
                      });
                    },
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          // 日历主体
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2010),
            lastDay: DateTime.utc(2040),
            headerVisible: false,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDateSelected(selectedDay); // 通知主页面选中的日期
              print("Selected Date: $selectedDay");
            },
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) =>
                  DateFormat("EEE").format(date).toUpperCase(),
              weekendStyle: TextStyle(fontWeight: FontWeight.bold),
              weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.warmOrange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.pinkpg,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.pinkpg,
                  shape: BoxShape.circle,
                )),
            eventLoader: (day) {
              return _events[day] ?? [];
            },
          ),
        ],
      ),
    );
  }
}
