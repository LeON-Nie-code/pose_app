import 'package:flutter/material.dart';
import 'package:pose_app/style/colors.dart';

class ProfileAvatar extends StatelessWidget {
  final Color avatarColor; // 动态头像颜色
  final bool isActive;
  final bool hasBorder;
  final VoidCallback? onTap; // 点击事件回调
  final String? userName; // 可选的用户名字段

  const ProfileAvatar({
    Key? key,
    required this.avatarColor,
    this.isActive = false,
    this.hasBorder = false,
    this.onTap,
    this.userName, // 可选的用户名
  }) : super(key: key);

  static void showColorPicker({
    required BuildContext context,
    required Color currentColor,
    required Function(Color) onColorSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            '选择头像颜色',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorOption(context, const Color.fromRGBO(255, 205, 210, 1), currentColor, onColorSelected),
                  _buildColorOption(context, const Color.fromRGBO(165, 214, 167, 1), currentColor, onColorSelected),
                  _buildColorOption(context, const Color.fromRGBO(144, 202, 249, 1), currentColor, onColorSelected),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorOption(context, const Color.fromRGBO(255, 249, 196, 1), currentColor, onColorSelected),
                  _buildColorOption(context, const Color.fromRGBO(206, 147, 216, 1), currentColor, onColorSelected),
                  _buildColorOption(context, const Color.fromRGBO(214, 214, 214, 1), currentColor, onColorSelected),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildColorOption(
    BuildContext context,
    Color color,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    return GestureDetector(
      onTap: () {
        onColorSelected(color); // 调用回调更新颜色
        Navigator.of(context).pop(); // 关闭弹窗
      },
      child: CircleAvatar(
        radius: 20.0,
        backgroundColor: color,
        child: currentColor == color
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundColor: AppColors.beige, // 外圈颜色
                child: CircleAvatar(
                  radius: hasBorder ? 17.0 : 20.0,
                  backgroundColor: avatarColor, // 内圈头像颜色
                ),
              ),
              if (isActive)
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    height: 15.0,
                    width: 15.0,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (userName != null) ...[
          const SizedBox(height: 4.0),
          Text(
            userName!,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
