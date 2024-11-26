import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pose_app/Community/dataAboutCommunity.dart';


// TODO: 获取后端提供的当前用户信息
// TODO: 点赞、关注等按钮的实际交互需通过后端接口实现

class AboutMyContainer extends StatelessWidget {
  //当前的用户（我）
  final User currentUser;

  AboutMyContainer({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      //height: 100.0,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            // 用户头像和输入框
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.white,
                backgroundImage: currentUser.assetImage != null
                    ? AssetImage(currentUser.assetImage!) // 本地图片
                    : currentUser.imageUrl != null
                        ? CachedNetworkImageProvider(currentUser.imageUrl!) // 网络图片
                        : AssetImage('assets/icons/default.png') as ImageProvider, // 默认图片
              ),
              const SizedBox(width: 8.0,),
              Expanded(
                child: TextField(
                  decoration: InputDecoration.collapsed(
                    hintText: '欢迎！'
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 10.0, thickness: 0.5,),
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
                  label: Text('FollowMe'),
                  ),
                const VerticalDivider(width: 8.0,),
                TextButton.icon(
                  onPressed: () => print('MyMoment'),
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.green,
                  ),
                  label: Text('MyMoment'),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
