import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';

class RecordListOfUsers extends StatefulWidget {
  final String? icon;
  final String? label;
  final String? amount;

  const RecordListOfUsers({
    Key? key,
    @required this.icon,
    this.label,
    this.amount,
  }) : super(key: key);

  @override
  _RecordListOfUsersState createState() => _RecordListOfUsersState();
}

class _RecordListOfUsersState extends State<RecordListOfUsers> {
  // 这里可以定义一些状态变量，例如：
  String? _statusLabel; // 假设我们想要动态改变状态标签

  @override
  void initState() {
    super.initState();
    // 初始化状态
    _statusLabel = widget.amount; // 初始状态可以是从属性中获取的值
    // 可以添加更多的初始化逻辑，比如网络请求等
  }

  // 提供更改状态的接口，例如一个方法来更新状态Label
  void updateStatusLabel(String newLabel) {
    setState(() {
      _statusLabel = newLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0, right: 20.0),
      visualDensity: VisualDensity.standard,
      leading: Container(
        width: 50.0,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SvgPicture.asset(widget.icon!, width: 20.0),
      ),
      title: PrimaryText(
        text: widget.label!,
        size: 14.0,
        fontWeight: FontWeight.w500,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PrimaryText(
            text: 'Successfully',
            size: 12.0,
            color: AppColors.secondary,
          ),
          PrimaryText(
            text: _statusLabel ?? widget.amount!, // 使用状态变量或属性值
            size: 16.0,
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
