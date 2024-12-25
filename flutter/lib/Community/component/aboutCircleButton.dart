// 圆形按钮组件，用于社区页面顶部菜单操作按钮

import 'package:flutter/material.dart';
import 'package:pose_app/style/colors.dart';

class CircleButton extends StatelessWidget {
  
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;

  const CircleButton({
    Key? key, 
    required this.icon, 
    required this.iconSize, 
    required this.onPressed
    }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: AppColors.refreshButton,
                shape: BoxShape.circle,
              ),
              child: IconButton(               
                icon: Icon(icon),
                iconSize: iconSize,
                color: AppColors.white,
                onPressed: onPressed,
              
              ),
            );
  }
}