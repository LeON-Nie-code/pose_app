//第一个和第二个container的三个部分（次数、时长、日均时长）

import 'package:flutter/material.dart';
import 'package:pose_app/style/colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const CustomCard({super.key, this.color, this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 170.0,
        minWidth: 150.0,
      ),
      padding: padding ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: color ?? AppColors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.2),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        //],
      ),
      child: child, // 将 child 添加到布局
    );
  }
}
