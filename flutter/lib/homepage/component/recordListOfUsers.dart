import 'dart:convert'; // 用于格式化JSON
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';
import 'package:intl/intl.dart';

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

    String formatDuration(dynamic durationInSeconds) {
    if (durationInSeconds == null) return '0分0秒';
    if (durationInSeconds is! num) return '0分0秒';
    int minutes = (durationInSeconds / 60).floor();
    int seconds = (durationInSeconds % 60).toInt();
    return '$minutes分$seconds秒';
  }

  String formatCreatedAt(String? createdAt) {
    if (createdAt == null) return 'N/A';
    try {
      // 使用DateFormat解析'EEE, dd MMM yyyy HH:mm:ss' GMT格式
      DateFormat format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
      DateTime parsedDate = format.parseUtc(createdAt);
      return DateFormat('yyyy/MM/dd HH:mm:ss').format(parsedDate);
    } catch (e) {
      print('Error formatting created_at: $e');
      return 'N/A';
    }
  }



  

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
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 12,
        backgroundColor: AppColors.beige,
        child: Container(
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 630,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.article, color: AppColors.primary, size: 28),
                      SizedBox(width: 8),
                      Text(
                        '记录详情',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.deppBeige,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            widget.record != null
                                ? JsonEncoder.withIndent('  ').convert(widget.record)
                                : 'No Record Available',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: AppColors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 35,),
                          Row(
                            children: [
                              Icon(Icons.label, color: AppColors.secondary),
                              SizedBox(width: 8),
                              Text('创建时间：\n ${formatCreatedAt(widget.record?['created_at'])}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ), 
                          Divider(),
                          Row(
                            children: [
                              Icon(Icons.label, color: AppColors.pinkpg),
                              SizedBox(width: 8),

                              Text('专注总时长：${formatDuration(widget.record?['eye_times']?['session_duration'])}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                               Icon(Icons.label, color: AppColors.warmOrange),
                                SizedBox(width: 8),
                              Text('弯腰：${formatDuration(widget.record?['posture_times']?['bow'])}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Icon(Icons.label, color: AppColors.yellowBr),
                              SizedBox(width: 8),
                              Text('左倾斜：${formatDuration(widget.record?['posture_times']?['left tilt'])}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Icon(Icons.label, color: AppColors.bluegrey),
                              SizedBox(width: 8),
                              Text('右倾斜：${formatDuration(widget.record?['posture_times']?['right tilt'])}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Icon(Icons.label, color: Colors.purple[200]),
                              SizedBox(width: 8),
                              Text('躺下：${formatDuration(widget.record?['posture_times']?['lying down in the chair'])}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          //Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warmOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
