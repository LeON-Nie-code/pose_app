import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart'; // 导入 Dio
import 'package:pose_app/Calendar/component/button.dart';
import 'package:pose_app/Calendar/component/inputContent.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';
import 'package:pose_app/Calendar/dataAboutTask.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTaskPage extends StatefulWidget {
  final DateTime selectedDate; // 选中的日期
  final Task? taskToEdit; // 可选的任务，用于编辑

  const AddTaskPage({
    Key? key,
    required this.selectedDate, // 必须传递 selectedDate
    this.taskToEdit, // 传递可选的 taskToEdit，用于编辑任务
  }) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late DateTime _selectedDate = widget.selectedDate; // 使用传入的 selectedDate

  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String access_token = '';

  // 创建 Dio 实例
  final Dio _dio = Dio();

  // // 从本地存储中获取 access_token
  // String storedAccessToken = '';
  // _getAccessToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   storedAccessToken = prefs.getString('access_token') ?? '';
  //   access_token = storedAccessToken;
  //   print('Access Token in addTaskpage: $access_token');
  // }

  // 从 SharedPreferences 中加载 accessToken
  Future<void> _initializeAccessToken() async {
    try {
      print('datatime.now: ${DateTime.now()}');
      print('selectedDate: $_selectedDate');

      final prefs = await SharedPreferences.getInstance();
      final storedAccessToken = prefs.getString('accessToken');
      if (storedAccessToken == null || storedAccessToken.isEmpty) {
        throw Exception('Access Token not found');
      }
      // 更新本地状态
      setState(() {
        access_token = storedAccessToken;
      });

      print(' access_token in addTaskPage: $access_token');

      // await _loadProfile(); // 加载用户信息
      // await _loadProfileUseAccessToken(); // 加载用户信息
    } catch (e, stackTrace) {
      // setState(() {
      //   isLoading = false;
      // });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法加载会话 ID: $e')),
      );
      // 打印错误详细信息到控制台
      print("Error: $e");
      print("StackTrace: $stackTrace");
    }
  }

  @override
  void initState() {
    super.initState();

    _initializeAccessToken();

    // 如果传入了 taskToEdit，初始化输入框内容
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title ?? "";
      _noteController.text = widget.taskToEdit!.note ?? "";
      _selectedDate = DateFormat('yyyy-MM-dd')
          .parse(widget.taskToEdit!.date ?? '2020.01.01');
      // _selectedRemind =
      //     int.parse(widget.taskToEdit!.remind?.split(" ")[0] ?? '5');
      _selectedRemind = 5;
      // TODO 暂时将_selectedRemind硬编码为为 5 分钟,因为点击编辑按钮时会报错，后续需要考虑一下Task.remind的处理
      // _selectedRemind = 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // 返回上一页
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                ),
                Expanded(child: SizedBox()),
                CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/userIcon.png'),
                  backgroundColor: Colors.white,
                  radius: 20,
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryText(
                      text: widget.taskToEdit == null ? '添加待办' : '编辑待办',
                      size: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 10),
                    InputContent(
                      hint: "请输入事项名称",
                      title: "事项",
                      controller: _titleController,
                    ),
                    SizedBox(height: 5),
                    InputContent(
                      hint: "请输入内容",
                      title: "备注",
                      controller: _noteController,
                    ),
                    SizedBox(height: 5),
                    InputContent(
                      hint: DateFormat('yyyy/MM/dd').format(_selectedDate),
                      title: "日期",
                      widget: IconButton(
                        onPressed: () async {
                          DateTime? _pickerDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),  builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: AppColors.warmOrange, 
                                scaffoldBackgroundColor:AppColors.beige, 
                                dialogBackgroundColor: AppColors.beige, 
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.warmOrange, 
                                  onPrimary: Colors.white, // 顶部选中日期的文字颜色
                                  surface: Colors.white,  // 日期选择背景颜色
                                  onSurface: Colors.black, // 日期文字颜色
                                ),
                              ),
                              child: child!,
                            );
                          },
                          );

                          if (_pickerDate != null) {
                            setState(() {
                              _selectedDate = _pickerDate;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    InputContent(
                      hint: "$_selectedRemind 分钟前提醒",
                      widget: DropdownButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                        iconSize: 32,
                        elevation: 4,
                        dropdownColor: const Color.fromARGB(255, 241, 241, 241),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        underline: Container(
                          height: 0,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRemind = int.parse(newValue!);
                          });
                        },
                        items: remindList
                            .map<DropdownMenuItem<String>>((int value) {
                          return DropdownMenuItem<String>(
                            value: value.toString(),
                            child: Text(value.toString()),
                          );
                        }).toList(),
                      ),
                      title: "提醒",
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyButton(
                          label: widget.taskToEdit == null
                              ? "添加"
                              : "更新", // 根据是否是编辑任务显示不同按钮
                          onTap: () => _validateData(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 验证输入的数据并发送 POST 请求
  _validateData(BuildContext context) async {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      // 创建新的任务数据
      final newTask = {
        "title": _titleController.text,
        "date":
            DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDate), // 格式化日期
        "note": _noteController.text,
        "remind_time": DateFormat('yyyy-MM-ddTHH:mm:ss').format(
            _selectedDate.subtract(Duration(minutes: _selectedRemind))), // 提醒时间
      };

      try {
        // 发送POST请求
        final response = await _dio.post(
          'http://8.217.68.60/user/todos',
          data: {
            "title": newTask['title'],
            "date": newTask['date'],
            "note": newTask['note'],
            "remind_time": newTask['remind_time'],
          },
          options: Options(headers: {
            'Authorization': 'Bearer $access_token', // 在请求头中添加 accessToken
          }), // 将 accessToken 添加到请求头
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 请求成功后返回新任务
          print('Response data: ${response.data}');
          if (mounted) {
            Future.delayed(Duration(milliseconds: 100), () {
              Task realTask = Task(
                  date: newTask['date'],
                  title: newTask['title'],
                  note: newTask['note'],
                  remind: newTask['remind_time']);
              Navigator.pop(context, realTask);
            });
          }
        } else {
          // 打印响应数据，查看后端错误信息
          print('Error response: ${response.data}');
          throw Exception('Failed to add task');
        }
      } catch (e) {
        // 请求失败，显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.highlight_off,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                "无法添加!您还没有输入事项",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
