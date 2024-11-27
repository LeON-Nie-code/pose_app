// lib/Communication/communication_page.dart
// TODO: 请求后端接口获取朋友圈社区数据

import 'package:flutter/material.dart';
import 'package:pose_app/Community/component/community_page.dart';
import 'package:pose_app/style/colors.dart';

class CommunicationPage extends StatelessWidget {
  const CommunicationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Community(), 
    );
  }
}

