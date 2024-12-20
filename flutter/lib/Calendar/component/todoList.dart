import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pose_app/Calendar/component/addTaskPage.dart';
import 'package:pose_app/Calendar/component/button.dart';
import 'package:pose_app/Calendar/component/taskBar.dart';
import 'package:pose_app/Community/component/profile_avatar.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';
import 'package:intl/intl.dart';
import 'package:pose_app/Calendar/dataAboutTask.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  _TodolistState createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  DateTime _selectedDate = DateTime.now(); // 当前选择的日期
  List<Task> tasks = []; // 存储所有任务
  Color _avatarColor = const Color.fromRGBO(248, 187, 208, 1); // 默认头像颜色为红色
  String access_token = '';

  @override
  void initState() {
    super.initState();
    _fetchTasks(); // 初始化时获取任务
  }

  Future<void> deleteTodo(int todo_id) async {
    // 使用 Dio 发起 GET 请求
    final dio = Dio();
    print('todolist access token: $access_token');
    try {
      final response = await dio.delete(
        'http://8.217.68.60/user/todos/$todo_id',
        options: Options(
          headers: {'Authorization': 'Bearer $access_token'},
        ),
      );
      // 处理成功的响应
      if (response.statusCode == 200) {
        print("Delete success");
      } else {
        throw Exception(
            "Failed to delete tasks, status code: ${response.statusCode}");
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        // 处理404错误
        print(e.response?.data);
      } else {
        // 处理其他DioError
        print(e.message);
      }
    }
  }

  // 从 API 获取任务列表
  Future<void> _fetchTasks() async {
    try {
      // 初始化 SharedPreferences 并获取 accessToken
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        throw Exception("Access token is missing");
      }

      access_token = accessToken;

      // 使用 Dio 发起 GET 请求
      final dio = Dio();
      final response = await dio.get(
        'http://8.217.68.60/user/todos',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      // 检查响应状态码
      if (response.statusCode == 200) {
        final data = response.data as List;

        // print(response.data);

        // 将 JSON 数据解析为 Task 列表
        setState(() {
          tasks = data.map((item) {
            return Task(
              userName: item['user_id'],
              title: item['title'],
              note: item['note'],
              date: item['date']?.split('T')?.first, // 提取日期部分
              remind: item['remind_time']?.split('T')?.last, // 提取时间部分
              isCompleted: 0, // 默认值（API 无 isCompleted 字段）
              id: item['id'],
            );
          }).toList();
        });

        print("Fetched tasks: $tasks");
      } else {
        throw Exception(
            "Failed to load tasks, status code: ${response.statusCode}");
      }

      print("Parsed tasks: $tasks");
    } catch (e) {
      // 错误处理
      print("Error fetching tasks: $e");
    }
  }

  // 添加或更新任务
  void addOrUpdateTask(Task task, {int? index}) {
    setState(() {
      if (index != null) {
        // 如果是更新任务，则替换任务
        tasks[index] = task;
      } else {
        // 如果是添加新任务
        tasks.add(task);
      }
    });
  }

  // 确认删除任务
  void _confirmDeleteTask(int index) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("确认删除"),
        content: Text("您确定要删除此任务吗？"),
        actions: <Widget>[
          TextButton(
            child: Text("取消"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("确认"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        tasks.removeAt(index); // 删除任务
        //TODO: 调用删除任务的 API 接口，删除数据库中的任务
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("in build,rendering tasks: $tasks");
    // 筛选出当前选择日期的任务
    List<Task> filteredTasks = tasks.where((task) {
      return DateFormat("yyyy-MM-dd").format(DateTime.parse(task.date!)) ==
          DateFormat("yyyy-MM-dd").format(_selectedDate);
    }).toList();

    // print("filtered tasks: $filteredTasks");

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      child: Column(
        children: [
          // 标题和头像
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryText(
                      text: '待办集',
                      size: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              //Expanded(child: SizedBox()),
              const Spacer(),
              // 可以选头像颜色并显示用户名
              ProfileAvatar(
                avatarColor: _avatarColor, // 动态头像颜色
                isActive: false,
                hasBorder: true,
                //userName: _userName, // 显示当前用户名
                onTap: () {
                  ProfileAvatar.showColorPicker(
                    context: context,
                    currentColor: _avatarColor,
                    onColorSelected: (selectedColor) {
                      setState(() {
                        _avatarColor = selectedColor;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          SizedBox(height: SizeConfig.blockSizeVertical! * 2),

          // 日期选择和新增任务按钮
          // 日期选择和新增任务按钮
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 日期显示部分
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryText(
                      text:
                          "${DateFormat("yyyy.MM.dd").format(DateTime.now())}",
                      size: 20.0,
                      color: AppColors.secondary,
                    ),
                    PrimaryText(
                      text: "Today",
                      size: 18.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),

                // 按钮部分
                Row(
                  children: [
                    FloatingActionButton(
                      onPressed: _fetchTasks,
                      child: Icon(Icons.refresh),
                      backgroundColor: AppColors.warmOrange,
                    ),
                    SizedBox(width: 8), // 调整两按钮之间的间距
                    MyButton(
                      label: "+ 添加",
                      onTap: () async {
                        // 跳转到添加/编辑任务页面，并接收返回的任务
                        Task? newTask = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddTaskPage(selectedDate: _selectedDate),
                          ),
                        );
                        if (newTask != null) {
                          addOrUpdateTask(newTask); // 添加新任务
                          //TODO: 调用添加任务的 API 接口
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 日期选择器
          Container(
            margin: const EdgeInsets.only(top: 20, left: 20),
            child: DatePicker(
              DateTime.now(),
              height: 100,
              width: 80,
              initialSelectedDate: DateTime.now(),
              selectionColor: AppColors.pinkpg.withOpacity(0.9),
              selectedTextColor: Colors.white,
              dateTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              onDateChange: (date) {
                setState(() {
                  _selectedDate = date; // 更新选择的日期
                });
              },
            ),
          ),
          SizedBox(height: 14),

          // 展示任务列表
          SizedBox(
            width: double.infinity,
            height: 300,
            child: ListView.builder(
              itemCount: filteredTasks.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(filteredTasks[index].title ?? index.toString()),
                  direction: DismissDirection.horizontal,
                  onDismissed: (_) {
                    _confirmDeleteTask(index); // 删除任务时弹出确认对话框
                    //TODO: 调用删除任务的 API 接口
                  },
                  background: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        Icons.delete_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      // 跳转到编辑任务页面
                      Task? updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskPage(
                            selectedDate: _selectedDate,
                            taskToEdit: filteredTasks[index],
                          ),
                        ),
                      );
                      if (updatedTask != null) {
                        // 更新任务
                        addOrUpdateTask(updatedTask, index: index);
                        //TODO: 调用更新任务的 API 接口，
                      }
                    },
                    child: TaskBar(task: filteredTasks[index]), // 渲染任务
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
