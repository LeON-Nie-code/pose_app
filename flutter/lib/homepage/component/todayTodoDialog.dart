import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pose_app/Calendar/dataAboutTask.dart';
import 'package:pose_app/Calendar/component/taskBar.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodayTodoDialog extends StatefulWidget {
  @override
  _TodayTodoDialogState createState() => _TodayTodoDialogState();
}

class _TodayTodoDialogState extends State<TodayTodoDialog> {
  List<Task> todayTasks = []; // 今日任务列表
  bool isLoading = true; // 是否正在加载任务

  @override
  void initState() {
    super.initState();
    _fetchTodayTasks(); // 获取今日任务
  }

  // 获取今日任务
  Future<void> _fetchTodayTasks() async {
    try {
      // 获取 accessToken
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        throw Exception("Access token is missing");
      }

      // 请求任务数据
      final dio = Dio();
      final response = await dio.get(
        'http://8.217.68.60/user/todos',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

        // 过滤今日任务
        setState(() {
          todayTasks = data
              .map((item) => Task(
                    title: item['title'],
                    note: item['note'],
                    date: item['date']?.split('T')?.first,
                    remind: item['remind_time']?.split('T')?.last,
                    isCompleted: 0,
                  ))
              .where((task) => task.date == today) // 筛选出今日的任务
              .toList();
          isLoading = false; // 数据加载完成
        });
      } else {
        throw Exception("Failed to fetch tasks");
      }
    } catch (e) {
      print("Error fetching today's tasks: $e");
      setState(() {
        isLoading = false; // 数据加载失败
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : todayTasks.isEmpty
                ? Center(
                    child: Text(
                      "今天暂时没有任务",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: todayTasks.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return TaskBar(task: todayTasks[index]); // 复用 TaskBar
                    },
                  ),
      ),
    );
  }
}
