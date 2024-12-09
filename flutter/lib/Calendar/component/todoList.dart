import 'package:date_picker_timeline/date_picker_timeline.dart';
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

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  _TodolistState createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  DateTime _selectedDate = DateTime.now(); // 当前选择的日期
  List<Task> tasks = []; // 存储所有任务

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
    // 筛选出当前选择日期的任务
    List<Task> filteredTasks = tasks.where((task) {
      return task.date == DateFormat("yyyy.MM.dd").format(_selectedDate);
    }).toList();

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
              Expanded(child: SizedBox()),
              ProfileAvatar(
                imageUrl: 'assets/icons/userIcon.png',
                isActive: false,
                hasBorder: true,
              ),
            ],
          ),
          SizedBox(height: SizeConfig.blockSizeVertical! * 2),

          // 日期选择和新增任务按钮
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryText(
                      text: "${DateFormat("yyyy.MM.dd").format(DateTime.now())}",
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
