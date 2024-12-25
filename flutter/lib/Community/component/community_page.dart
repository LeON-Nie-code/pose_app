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
import 'package:pose_app/Community/dataAboutCommunity.dart';
import 'package:pose_app/config/config.dart';

// TODO: 后端接口需求
// - 获取当前用户信息
// - 获取帖子列表（支持分页）
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
  bool _isLoading = true; // 添加加载状态
  int currentPage = 1; // 当前页码
  int totalPages = 1; // 总页数

  @override
  void initState() {
    super.initState();
// 初始化状态
    initThePost();
  }

  void initThePost() async {
    setState(() {
      _isLoading = true; // 开始加载
    });
    await createDocumentFolder();
    await getAccessToken();
    await getPostsAndSaveImages(access_token, currentPage);
    setState(() {
      _isLoading = false; // 加载完成
    });
  }

  Future<void> loadPosts() async {
    _posts.clear();
  }

  Future<void> createDocumentFolder() async {
    final directory = await getApplicationDocumentsDirectory();
    String newFolderName = 'pose_app';
    String newFolderPath = '${directory.path}/$newFolderName';
    Directory newFolder = Directory(newFolderPath);

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

  Future<void> getPostsAndSaveImages(String token, int page) async {
    final dio = Dio();
    final String url = '${Config.baseUrl}/all_posts?page=$page'; // 添加分页参数

    setState(() {
      _posts.clear(); // 清空现有帖子
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

      if (response.statusCode == 200) {
        List<dynamic> posts = response.data['posts']; // 获取帖子列表
        for (var post in posts) {
          print('Post content: ${post['content']}');
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
// print("type of post[comments] is ${post['comments'].runtimeType}");
          print("post[comments] is ${post['comments']}");
          // 检查 post['comments'] 是否为 null，如果是 null 则传递一个空的列表
          // final List<Map<String, dynamic>> comments = post['comments'] != null
          //     ? List<Map<String, dynamic>>.from(post['comments'])
          //     : [];

          List<Comment> comments = [];
          if (post['comments'] != null) {
            comments = parseComments(jsonEncode(post['comments']));
          }

          final newPost = Post(
              user: currentUser,
              caption: post['content'],
              timeAgo: post['date_posted'],
              assetImages: assetImages, // 使用实际图片数量
              likes: post['likes']?.toInt() ?? 0,
              comments: 0,
              shares: 0,
              post_id: post['post_id'],
              commentsContent: comments);
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

        // 更新分页信息（假设后端返回分页数据）
        totalPages = response.data['total_pages'];
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
      currentPage = 1;
      _isLoading = true;
    });

    //延迟0.5秒
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });

    getPostsAndSaveImages(access_token, currentPage).then((_) {
      setState(() {
        _isLoading = false;
      });
    });

    // setState(() {
    //   _posts.insert(0, newPost); // 将新帖子添加到顶部
    // });
  }

  void _navigateToAddPostPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostPage(onPostAdded: _addNewPost),
      ),
    );
  }

  void _loadNextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
        _isLoading = true;
      });
      getPostsAndSaveImages(access_token, currentPage).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _loadPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        _isLoading = true;
      });
      getPostsAndSaveImages(access_token, currentPage).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _goToPage(int page) {
    setState(() {
      currentPage = page;
      _isLoading = true;
    });
    getPostsAndSaveImages(access_token, currentPage).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
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
              color: Colors.black,
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
          child: AboutMyContainer(),
        ),
        if (_isLoading)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: CircularProgressIndicator(),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final Post post = _posts[index];
                return Postcontainer(post: post);
              },
              childCount: _posts.length,
            ),
          ),
        // 添加分页按钮
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _loadPreviousPage,
                ),
                Text('Page $currentPage of $totalPages'),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _loadNextPage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Comment> parseComments(String jsonString) {
    final List<dynamic> commentsJson = json.decode(jsonString);
    return commentsJson.map((commentJson) {
      return Comment.fromJson(commentJson);
    }).toList();
  }
}
