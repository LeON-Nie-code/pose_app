// lib/Community/component/community_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pose_app/Community/component/aboutCircleButton.dart';
import 'package:pose_app/Community/component/aboutMyContainer.dart';
import 'package:pose_app/Community/component/postContainer.dart';
import 'package:pose_app/Community/component/add_post_page.dart';
import 'package:pose_app/Community/dataAboutCommunity.dart';
import 'package:pose_app/style/colors.dart';

// TODO: 后端接口需求
// - 获取当前用户信息
// - 获取帖子列表
// - 提交新帖子（带图片）


class Community extends StatefulWidget {
  const Community({super.key});

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final List<Post> _posts = List.from(posts); // 深拷贝初始帖子列表

  // TODO: 将新帖子提交至后端数据库并刷新前端显示
  void _addNewPost(Post newPost) {
    setState(() {
      _posts.insert(0, newPost); // 将新帖子添加到顶部
    });
  }

  void _navigateToAddPostPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostPage(onPostAdded: _addNewPost),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.white,
          title: const Text(
            '朋友圈',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.2,
            ),
          ),
          centerTitle: false,
          floating: true,
          actions: [
            CircleButton(
              icon: Icons.more_horiz,
              iconSize: 30.0,
              onPressed: () => print('SearchMyFollow'),
            ),
            CircleButton(
              icon: Icons.add,
              iconSize: 30.0,
              onPressed: _navigateToAddPostPage,
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: AboutMyContainer(currentUser: currentUser),
        ),
        // 动态列表展示
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final Post post = _posts[index];
              return Postcontainer(post: post);
            },
            childCount: _posts.length,
          ),
        ),
      ],
    );
  }
}
