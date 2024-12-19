// lib/Community/component/community_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pose_app/Community/component/aboutCircleButton.dart';
import 'package:pose_app/Community/component/aboutMyContainer.dart';
import 'package:pose_app/Community/component/postContainer.dart';
import 'package:pose_app/Community/component/add_post_page.dart';
import 'package:pose_app/Community/dataAboutCommunity.dart';
import 'package:pose_app/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

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

  String access_token = '';

  String documentPath = '';

  @override
  void initState() {
    super.initState();
    // 初始化状态
    initThePost();
  }

  void initThePost() async {
    await createDocumentFolder();
    await getAccessToken();
    await getPostsAndSaveImages(access_token);
  }

  Future<void> loadPosts() async {
    _posts.clear();
  }

  Future<void> createDocumentFolder() async {
    // 获取应用的文档目录
    final directory = await getApplicationDocumentsDirectory();
    print("application document directory: ${directory.path}");

    // 定义新文件夹的名称
    String newFolderName = 'pose_app';

    // 创建新文件夹的完整路径
    String newFolderPath = '${directory.path}/$newFolderName';

    // 创建Directory对象
    Directory newFolder = Directory(newFolderPath);

    // 检查文件夹是否已经存在
    if (!await newFolder.exists()) {
      // 如果文件夹不存在，则创建文件夹
      await newFolder.create(recursive: true);
      print('New folder created at: $newFolderPath');
    } else {
      print('Folder already exists at: $newFolderPath');
    }

    documentPath = newFolderPath;
  }

  Future<void> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAccessToken = prefs.getString('accessToken');
    if (storedAccessToken == null || storedAccessToken.isEmpty) {
      throw Exception('Access Token not found');
    }
    // 更新本地状态
    access_token = storedAccessToken;
  }

  Future<void> getPostsAndSaveImages(String token) async {
    final dio = Dio();
    const String url = 'http://8.217.68.60/all_posts'; // 获取所有posts的API

    setState(() {
      _posts.clear();
    });

    try {
      // 发送 GET 请求
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // 携带 JWT token
          },
        ),
      );

      // 检查响应
      if (response.statusCode == 200) {
        List<dynamic> posts = response.data;

        // 遍历帖子数据
        for (var post in posts) {
          print('Post: ${post['title']}');
          int post_img_count = 0;

          // 处理每张图片
          for (int i = 1; i <= 3; i++) {
            String? encodedPhoto = post['photo$i'];
            if (encodedPhoto != null) {
              // 提取 Base64 编码的图片
              String base64Image =
                  encodedPhoto.replaceFirst('data:image/jpeg;base64,', '');

              // 解码图片
              List<int> imageBytes = base64Decode(base64Image);
              final filePath =
                  '$documentPath/post_${post['post_id']}_photo$i.jpg';

              final file = File(filePath);

              // 将图像数据保存到文件
              await file.writeAsBytes(imageBytes);
              print('Image saved to: $filePath');
              post_img_count++; // 成功写入图片，增加计数器
              //load posts
            }
          }

          // 创建新帖子对象，根据实际图片数量创建
          List<String> assetImages = [];
          for (int i = 1; i <= post_img_count; i++) {
            assetImages
                .add('${documentPath}/post_${post['post_id']}_photo$i.jpg');
          }
          final newPost = Post(
            user: currentUser,
            caption: post['content'],
            timeAgo: post['date_posted'],
            assetImages: assetImages, // 使用实际图片数量
            likes: 0,
            comments: 0,
            shares: 0,
            post_id: post['post_id'],
          );
          _posts.add(newPost);
          print("Post added: ${newPost.timeAgo}");
        }

        print('Posts loaded successfully!');

        setState(() {
          // 排序 _posts 列表，最新的帖子在最前面
          _posts.sort((post1, post2) {
            return (parseDateTime(post2.timeAgo))
                .compareTo(parseDateTime(post1.timeAgo));
          });
        });
      } else {
        print('Failed to load posts: ${response.statusCode}');
      }
    } on DioError catch (e) {
      print('Error occurred: ${e.response?.data ?? e.message}');
    }
  }

  // 自定义解析函数
  DateTime parseDateTime(String dateString) {
    return DateFormat('EEE, dd MMM yyyy HH:mm:ss ')
        .parse(dateString)
        .add(Duration(hours: 8)); // 添加3小时以考虑GMT
  }

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
              icon: Icons.refresh,
              iconSize: 30.0,
              // onPressed: () => print('SearchMyFollow'),
              onPressed: () => initThePost(),
            ),
            CircleButton(
              icon: Icons.add,
              iconSize: 30.0,
              onPressed: _navigateToAddPostPage,
            ),
          ],
        ),
        SliverToBoxAdapter(
          //child: AboutMyContainer(currentUser: currentUser),
          child: AboutMyContainer(),
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
