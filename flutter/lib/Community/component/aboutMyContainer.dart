import 'package:flutter/material.dart';
import 'package:pose_app/Community/component/profile_avatar.dart';

class AboutMyContainer extends StatefulWidget {
  const AboutMyContainer({Key? key}) : super(key: key);

  @override
  _AboutMyContainerState createState() => _AboutMyContainerState();
}

class _AboutMyContainerState extends State<AboutMyContainer> {
  Color _avatarColor = const Color.fromRGBO(248, 187, 208, 1); // 默认头像颜色

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            // 用户头像和输入框
            children: [
              ProfileAvatar(
                avatarColor: _avatarColor, // 动态头像颜色
                isActive: false, // 是否显示激活状态
                hasBorder: true, // 是否显示边框
                onTap: () {
                  ProfileAvatar.showColorPicker(
                    context: context,
                    currentColor: _avatarColor,
                    onColorSelected: (selectedColor) {
                      setState(() {
                        _avatarColor = selectedColor; // 更新头像颜色
                      });
                    },
                  );
                },
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  decoration: InputDecoration.collapsed(
                    hintText: '欢迎！',
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 10.0, thickness: 0.5),
          Container(
            height: 40.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => print('FollowMe'),
                  icon: const Icon(
                    Icons.list,
                    color: Colors.red,
                  ),
                  label: const Text('FollowMe'),
                ),
                const VerticalDivider(width: 8.0),
                TextButton.icon(
                  onPressed: () => print('MyMoment'),
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.green,
                  ),
                  label: const Text('MyMoment'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
