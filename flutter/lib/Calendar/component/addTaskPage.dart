import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pose_app/Calendar/component/button.dart';
import 'package:pose_app/Calendar/component/inputContent.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';
import 'package:pose_app/Calendar/dataAboutTask.dart'; 

class AddTaskPage extends StatefulWidget {
  final DateTime selectedDate; // 选中的日期
  final Task? taskToEdit; // 可选的任务，用于编辑

  const AddTaskPage({
    Key? key,
    required this.selectedDate,  // 必须传递 selectedDate
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

  @override
  void initState() {
    super.initState();

    // 如果传入了 taskToEdit，初始化输入框内容
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title ?? "";
      _noteController.text = widget.taskToEdit!.note ?? "";
      _selectedDate = DateFormat('yyyy.MM.dd').parse(widget.taskToEdit!.date ?? '2020.01.01');
      _selectedRemind = int.parse(widget.taskToEdit!.remind?.split(" ")[0] ?? '5');
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
                            lastDate: DateTime(2030),
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
                      hint: "$_selectedRemind minutes early",
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
                          label: widget.taskToEdit == null ? "添加" : "更新", // 根据是否是编辑任务显示不同按钮
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

  // 验证输入的数据并返回任务对象
  _validateData(BuildContext context) {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      // 创建 Task 对象
      Task newTask = Task(
        title: _titleController.text,
        note: _noteController.text,
        date: DateFormat('yyyy.MM.dd').format(_selectedDate),
        remind: "$_selectedRemind minutes",
        isCompleted: 0,
      );

      // 如果是编辑任务，传回修改后的任务；如果是新任务，添加新任务
      Navigator.pop(context, newTask);
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
