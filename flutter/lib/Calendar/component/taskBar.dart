import 'package:flutter/material.dart';
import 'package:pose_app/Calendar/component/addTaskPage.dart';
import 'package:pose_app/Calendar/dataAboutTask.dart';
import 'package:pose_app/style/colors.dart';
import 'package:intl/intl.dart'; // 用于日期格式化

class TaskBar extends StatefulWidget {
  final Task task; // 定义一个 Task 类型的变量

  const TaskBar({
    super.key,
    required this.task, // 必须传入 task 参数
  });

  @override
  _TaskBarState createState() => _TaskBarState();
}

class _TaskBarState extends State<TaskBar> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task; // 初始化任务
  }

  // 切换任务完成状态
  void _toggleCompletion() {
    setState(() {
      _task.isCompleted = _task.isCompleted == 0 ? 1 : 0; // 完成任务时置为1，未完成为0
       //TODO: 调用更新任务完成状态的 API 接口
    });
  }

  @override
  Widget build(BuildContext context) {
    // 设置Container的颜色
    Color containerColor = _task.isCompleted == 0
        ? AppColors.yellowBr.withOpacity(0.3) // 未完成时黄色
        : Colors.green.withOpacity(0.3); // 完成时绿色

    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: containerColor, // 使用动态颜色
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        duration: const Duration(milliseconds: 600),
        child: ListTile(
          leading: GestureDetector(
            onTap: _toggleCompletion, // 切换完成状态
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                color: _task.isCompleted == 0 ? AppColors.warmOrange : Colors.green, // 完成时为绿色，未完成为橙色
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: .8),
              ),
              child: Icon(
                _task.isCompleted == 0 ? Icons.circle : Icons.check, // 完成时显示勾选
                color: Colors.white,
              ),
            ),
          ),
          // 任务标题
          title: Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 3),
            child: Text(
              _task.title ?? '任务事项', // 使用 task 中的 title
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 任务内容（备注）
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _task.note ?? '内容', // 使用 task 中的 note
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w800,
                ),
              ),
              // 日期
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _task.date ?? 'Date', // 使用 task 中的 date
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // 点击编辑按钮，跳转到编辑任务页面
              Task? updatedTask = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskPage(
                    selectedDate: DateTime.now(),
                    taskToEdit: _task, // 传递当前任务进行编辑
                  ),
                ),
              );
              if (updatedTask != null) {
                // 如果编辑任务有返回数据，更新任务
                setState(() {
                  _task = updatedTask; // 更新当前任务
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
