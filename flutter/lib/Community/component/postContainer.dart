import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pose_app/Community/component/full_screen_image.dart';
import 'package:pose_app/Community/component/profile_avatar.dart';
import 'package:pose_app/Community/dataAboutCommunity.dart';
import 'package:pose_app/style/colors.dart';

// TODO: 点赞、评论、分享等交互需要后端接口支持
// TODO: 动态刷新点赞、评论数量时，需要请求后端更新数据
//添加后端图片上传接口：将图片数据发送到后端存储，并返回一个 URL。

class Postcontainer extends StatelessWidget {
  final Post post;

  const Postcontainer({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PostHeader(post: post),
                const SizedBox(height: 4.0),
                Text(post.caption),
                const SizedBox(height: 6.0),
              ],
            ),
          ),
          // 展示多张图片
          if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  for (int i = 0; i < post.imageUrls!.length; i += 3)
                    Row(
                      children: post.imageUrls!
                          .skip(i)
                          .take(3)
                          .map(
                            (imageUrl) => Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _navigateToFullScreenImage(context, imageUrl),
                                child: Container(
                                  height: 200.0, // 固定高度
                                  margin: const EdgeInsets.all(4.0),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.contain, // 确保完整显示图片
                                    placeholder: (context, url) =>
                                        const Center(
                                            child:
                                                CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error, size: 50),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            )
          else if (post.assetImages != null && post.assetImages!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  for (int i = 0; i < post.assetImages!.length; i += 3)
                    Row(
                      children: post.assetImages!
                          .skip(i)
                          .take(3)
                          .map(
                            (assetImage) => Expanded(
                              child: GestureDetector(
                                onTap: () => _navigateToFullScreenImage(
                                    context, assetImage),
                                child: Container(
                                  height: 200.0, // 固定高度
                                  margin: const EdgeInsets.all(4.0),
                                  child: Image.file(
                                    File(assetImage),
                                    fit: BoxFit.contain, // 确保完整显示图片
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _PostStats(post: post),
          ),
        ],
      ),
    );
  }

  // 导航到全屏图片页面
  void _navigateToFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imagePath: imagePath),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final Post post;

  const _PostHeader({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
          //imageUrl: post.user.imageUrl ?? 'https://example.com/default.png',
          avatarColor: post.user.avatarColor, 
          isActive: false,
          hasBorder: true,    
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.user.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                post.timeAgo,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}

class _PostStats extends StatelessWidget {
  final Post post;

  const _PostStats({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: AppColors.deppBeige,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thumb_up,
                size: 10.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                '${post.likes}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            _PostButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.grey[600],
                size: 20.0,
              ),
              label: 'Like',
              onTap: () => print('Like'),
            ),
            _PostButton(
              icon: Icon(
                Icons.message,
                color: Colors.grey[600],
                size: 20.0,
              ),
              label: 'Comment',
              onTap: () => print('Comment'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PostButton extends StatelessWidget {
  final Icon icon;
  final String label;
  final GestureTapCallback onTap;

  const _PostButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            height: 25.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 4.0),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
