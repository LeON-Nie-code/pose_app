import 'dart:convert'; // 用于格式化JSON
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';

class RecordListOfUsers extends StatefulWidget {
  final String? icon;
  final String? label;
  final String? amount;
  final DateTime? selectedDate;
  final Map<String, dynamic>? record; // 修改类型为 Map<String, dynamic>

  const RecordListOfUsers({
    Key? key,
    @required this.icon,
    this.label,
    this.amount,
    this.selectedDate,
    this.record,
  }) : super(key: key);

  @override
  _RecordListOfUsersState createState() => _RecordListOfUsersState();
}

class _RecordListOfUsersState extends State<RecordListOfUsers> {
  String? _statusLabel;

  static const List<String> month = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _statusLabel = widget.amount;
  }

  void _showRecordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Record Details'),
          content: SingleChildScrollView(
            child: Text(
              widget.record != null
                  ? JsonEncoder.withIndent('  ')
                      .convert(widget.record) // 格式化JSON
                  : 'No Record Available',
              style: TextStyle(fontSize: 14.0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
            text: widget.selectedDate != null
                ? '${widget.selectedDate!.day} ${month[widget.selectedDate!.month]} ${widget.selectedDate!.year}'
                : '02 Mar 20xx（例子）',
            size: 12.0,
            color: AppColors.secondary,
          ),
          PrimaryText(
            text: _statusLabel ?? widget.amount!,
            size: 16.0,
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
      onTap: _showRecordDialog, // 添加点击回调
    );
  }
}
