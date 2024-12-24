import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pose_app/Community/component/full_screen_image.dart';
import 'package:pose_app/Community/component/profile_avatar.dart';
import 'package:pose_app/Community/dataAboutCommunity.dart';
import 'package:pose_app/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: 点赞、评论、分享等交互需要后端接口支持
// TODO: 动态刷新点赞、评论数量时，需要请求后端更新数据
//添加后端图片上传接口：将图片数据发送到后端存储，并返回一个 URL。

class Postcontainer extends StatefulWidget {
  final Post post;

  const Postcontainer({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  _PostcontainerState createState() => _PostcontainerState();
}

class _PostcontainerState extends State<Postcontainer> {
  int _currentImageIndex = 0; // 当前显示的图片索引
  late PageController _pageController;
  String access_token = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentImageIndex);
    getAccessToken();
  }

  void getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAccessToken = prefs.getString('accessToken');
    if (storedAccessToken == null || storedAccessToken.isEmpty) {
      throw Exception('Access Token not found');
    }
    // 更新本地状态
    access_token = storedAccessToken;
  }

  Future<void> postLike({required int post_id}) async {
    final dio = Dio();
    String url = 'http://8.217.68.60/post/$post_id/like'; // 替换为实际的 API 地址
    try {
      // 发送 POST 请求
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $access_token', // 携带 JWT token
          },
          // contentType: 'multipart/form-data', // 确保内容类型正确
        ),
      );

      // 检查响应
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Post liked successfully!');
      } else {
        print('Failed to like post: ${response.data}');
      }
    } on DioException catch (e) {
      print('Error occurred: ${e.response?.data ?? e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请求失败')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                _PostHeader(post: widget.post),
                const SizedBox(height: 4.0),
                Text(
                  widget.post.caption,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                  ),
                ),
                const SizedBox(height: 6.0),
              ],
            ),
          ),
          // 展示第一张图片，并允许通过左右按钮切换图片
          if (widget.post.imageUrls != null &&
              widget.post.imageUrls!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      //到时候会删除第一个if，而会直接用else if部分（因为这个部分是本地的图片展示，而不是新添加后的的container）
                      Container(
                        height: 400.0,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.post.imageUrls!.length,
                          itemBuilder: (context, index) {
                            final imageUrl = widget.post.imageUrls![index];
                            return GestureDetector(
                              onTap: () {
                                _navigateToFullScreenImage(context, imageUrl);
                              },
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain, // 确保完整显示图片
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error, size: 50),
                              ),
                            );
                          },
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                        ),
                      ),
                      Positioned(
                        left: 15.0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_left,
                            size: 50,
                          ),
                          onPressed: _currentImageIndex > 0
                              ? () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 15.0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_right,
                            size: 50,
                          ),
                          onPressed: _currentImageIndex <
                                  widget.post.imageUrls!.length - 1
                              ? () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          // 处理本地图片的显示
          else if (widget.post.assetImages != null &&
              widget.post.assetImages!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 400.0,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.post.assetImages!.length,
                          itemBuilder: (context, index) {
                            final assetImage = widget.post.assetImages![index];
                            return GestureDetector(
                              onTap: () {
                                _navigateToFullScreenImage(context, assetImage);
                              },
                              child: Image.file(
                                File(assetImage),
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                        ),
                      ),
                      Positioned(
                        left: 10.0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_left,
                            size: 50,
                          ),
                          onPressed: _currentImageIndex > 0
                              ? () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 10.0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_right,
                            size: 50,
                          ),
                          onPressed: _currentImageIndex <
                                  widget.post.assetImages!.length - 1
                              ? () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _PostStats(post: widget.post),
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

class _PostStats extends StatefulWidget {
  final Post post;

  const _PostStats({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<_PostStats> createState() => _PostStatsState();
}

class _PostStatsState extends State<_PostStats> {
  int likeCount = 0; // 初始点赞数
  List<Map<String, String>> comments = []; // 修改为存储评论内容和用户 ID 的列表
  String access_token = '';
  String? user_name = '';

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likes; // 设置初始值
    _initializeData();
  }

  Future<void> _initializeData() async {
    // 先获取 AccessToken
    await getAccessToken(); // 确保 getAccessToken 执行完成后再继续执行
    fetchUserName().then((value) {
      if (mounted) {
        setState(() {
          user_name = value;
        });
        loadComments();
      }
    });
  }

  void loadComments() async {
    // 从post.commentsContent加载评论
    for (var comment in widget.post.commentsContent) {
      comments.add({
        'content': comment.content,
        'user_name': comment.username,
      });
    }
  }

  void _incrementLike() {
    postLike(post_id: widget.post.post_id);
    print(widget.post.likes);
    setState(() {
      likeCount++;
    });
    print(widget.post.commentsContent);
  }

  Future<void> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAccessToken = prefs.getString('accessToken');
    if (storedAccessToken == null || storedAccessToken.isEmpty) {
      throw Exception('Access Token not found');
    }
    // 更新本地状态
    access_token = storedAccessToken;
    // print('access_token in getAccessToken: $access_token');
  }

  Future<String?> fetchUserName() async {
    final dio = Dio();
    String url = 'http://8.217.68.60/user_info';
    // print('access_token in fetchUserName: $access_token');
    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $access_token', // 携带 JWT token
          },
          // contentType: 'multipart/form-data', // 确保内容类型正确
        ),
      ); // 调用 GET 请求
      if (response.statusCode == 200) {
        final data = response.data; // 获取返回的 JSON 数据
        // print('User name: ${data['username']}');
        return data['username']; // 提取 `username`
      } else {
        print("Error: ${response.data}");
        return null;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print("Dio error: ${e.response?.data}");
      } else {
        print("Error: ${e.message}");
      }
      return null;
    }
  }

  Future<void> postComment({
    required int post_id,
    required String comment,
  }) async {
    final dio = Dio();
    String url = 'http://8.217.68.60/post/$post_id/comment';

    try {
      // 发送 POST 请求
      final response = await dio.post(
        url,
        data: {
          'content': comment, // 评论内容
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $access_token', // 携带 JWT token
            'Content-Type': 'application/json',
          },
        ),
      );

      // 检查响应
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Post commented successfully!');
        print('Response Data: ${response.data}');
      } else {
        print('Failed to comment post: ${response.data}');
      }
    } on DioException catch (e) {
      print('Error occurred: ${e.response?.data ?? e.message}');
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请求失败')),
      );
    }
  }

  Future<void> postLike({required int post_id}) async {
    final dio = Dio();
    String url = 'http://8.217.68.60/post/$post_id/like'; // 替换为实际的 API 地址
    try {
      // 发送 POST 请求
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $access_token', // 携带 JWT token
          },
          // contentType: 'multipart/form-data', // 确保内容类型正确
        ),
      );

      // 检查响应
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Post liked successfully!');
      } else {
        print('Failed to like post: ${response.data}');
      }
    } on DioException catch (e) {
      print('Error occurred: ${e.response?.data ?? e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请求失败')),
      );
    }
  }

  void _addComment(String comment) {
    if (user_name == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('评论不能为空')),
      );
      return;
    }
    postComment(post_id: widget.post.post_id, comment: comment);
    setState(() {
      comments.add({'content': comment, 'user_name': user_name ?? ''}); // 使用默认值
    });
  }

  void _showCommentDialog(BuildContext context) {
    String commentText = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("添加评论"),
          content: TextField(
            onChanged: (value) {
              commentText = value;
            },
            decoration: const InputDecoration(hintText: "发表评论"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                if (commentText.isNotEmpty) {
                  _addComment(commentText);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('评论不能为空')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text("发送"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Likes: $likeCount',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Spacer(),
            Text(
              '${comments.length} Comments',
              style: TextStyle(color: Colors.grey[600]),
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
              onTap: _incrementLike,
            ),
            _PostButton(
              icon: Icon(
                Icons.message,
                color: Colors.grey[600],
                size: 20.0,
              ),
              label: 'Comment',
              onTap: () => _showCommentDialog(context),
            ),
          ],
        ),
        if (comments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: comments.map((comment) {
                return Text(
                  "- ${comment['user_name']}: ${comment['content']}",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                );
              }).toList(),
            ),
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
