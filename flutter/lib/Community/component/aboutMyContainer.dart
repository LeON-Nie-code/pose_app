import 'package:flutter/material.dart';
import 'package:pose_app/Community/component/profile_avatar.dart';

class AboutMyContainer extends StatefulWidget {
  const AboutMyContainer({Key? key}) : super(key: key);

  @override
  _AboutMyContainerState createState() => _AboutMyContainerState();
}

class _AboutMyContainerState extends State<AboutMyContainer> {
  Color _avatarColor = const Color.fromRGBO(248, 187, 208, 1); // 默认头像颜色

  // 模拟好友列表
  final List<String> friends = [
    for (int i = 1; i <= 10; i++) 'Friend $i', // 模拟 30 个好友
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              ProfileAvatar(
                avatarColor: _avatarColor,
                isActive: false,
                hasBorder: true,
                onTap: () {
                  ProfileAvatar.showColorPicker(
                    context: context,
                    currentColor: _avatarColor,
                    onColorSelected: (selectedColor) {
                      setState(() {
                        _avatarColor = selectedColor;
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
                GestureDetector(
                  onTapDown: (TapDownDetails details) =>
                      _showFriendListPopup(context, details),
                  child: TextButton.icon(
                    onPressed: () {}, // 按钮默认行为为空
                    icon: const Icon(Icons.list, color: Colors.red),
                    label: const Text('FollowMe'),
                  ),
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

  // 显示好友列表弹窗
  void _showFriendListPopup(BuildContext context, TapDownDetails details) {
    // 获取点击位置
    final Offset position = details.globalPosition;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: position.dx + 50, // 按钮右侧 50 像素
              top: position.dy - 20, // 按钮顶部对齐
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  height: 300, // 设置窗口固定高度
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "我的好友",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.person, color: Colors.blue),
                              title: Text(friends[index]),
                              onTap: () {
                                print("Selected friend: ${friends[index]}");
                                Navigator.of(context).pop(); // 关闭弹窗
                              },
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "关闭",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
