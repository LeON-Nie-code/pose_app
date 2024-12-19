import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pose_app/Community/dataAboutCommunity.dart';
import 'package:pose_app/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 添加新帖子的页面
// TODO: 后端接口需求
// - 图片上传接口：将用户选择的图片上传到后端存储并获取图片的 URL （其他办法也可以）
// - 提交帖子接口：将帖子内容和图片 URL 提交给后端保存

class AddPostPage extends StatefulWidget {
  final Function(Post) onPostAdded;

  const AddPostPage({Key? key, required this.onPostAdded}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _selectedFiles = []; // 存储多张图片

  String access_token = '';

  @override
  void initState() {
    super.initState();
    // 初始化状态
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

  // 打开文件选择对话框
  Future<void> _selectFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // 允许选择多个文件
    );

    if (result != null) {
      final newFiles = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      setState(() {
        // 过滤掉重复的文件
        _selectedFiles.addAll(
          newFiles.where((newFile) => !_selectedFiles
              .any((existingFile) => existingFile.path == newFile.path)),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未选择图片')),
      );
    }
  }

  Future<void> createPost({
    required String token,
    required String title,
    required String content,
    List<String>? imagePaths, // 图片文件路径列表
  }) async {
    final dio = Dio();
    const String url = 'http://8.217.68.60/post'; // 替换为实际的 API 地址

    try {
      // 构造表单数据
      final formData = FormData.fromMap({
        'title': title,
        'content': content,
        if (imagePaths != null)
          for (int i = 0; i < imagePaths.length && i < 3; i++)
            'photo${i + 1}': await MultipartFile.fromFile(imagePaths[i]),
      });

      // 发送 POST 请求
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // 携带 JWT token
          },
          contentType: 'multipart/form-data', // 确保内容类型正确
        ),
      );

      // 检查响应
      if (response.statusCode == 201) {
        print('Post created successfully!');
      } else {
        print('Failed to create post: ${response.data}');
      }
    } on DioException catch (e) {
      print('Error occurred: ${e.response?.data ?? e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请求失败')),
      );
    }
  }

  // 提交帖子
  Future<void> _submitPost() async {
    //删除了对于上传图片的判断，可以只上传文字
    if (_descriptionController.text.isNotEmpty) {
      // TODO: 调用后端图片上传接口，将图片文件上传到后端并获取 URL
      // 示例：List<String> imageUrls = await uploadImagesToServer(_selectedFiles);

      // 创建 Dio 实例

      List<String> imagePaths =
          _selectedFiles.map((file) => file.path).toList();

      await createPost(
        token: access_token,
        title: "auto_title",
        content: _descriptionController.text,
        imagePaths: imagePaths,
      );

      // 检查响应状态

      final newPost = Post(
        user: currentUser,
        caption: _descriptionController.text,
        timeAgo: '刚刚',
        imageUrls: null,
        assetImages:
            _selectedFiles.map((file) => file.path).toList(), // 存储多个本地路径
        likes: 0,
        comments: 0,
        shares: 0,
        post_id: 999, // 临时 ID
      );

      // TODO: 调用后端提交帖子接口，将帖子内容和图片 URL 一起发送到后端
      // 示例：await submitPostToServer(newPost);

      widget.onPostAdded(newPost);
      Navigator.pop(context); // 返回上一页
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写描述并选择图片')),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: const Text('添加新帖子'),
        backgroundColor: AppColors.beige,
        actions: [
          ElevatedButton.icon(
            onPressed: _submitPost,
            icon: const Icon(
              Icons.send,
              color: AppColors.secondary,
            ),
            label: const Text(
              '发布',
              style: TextStyle(color: AppColors.secondary),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              backgroundColor: AppColors.deppBeige,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  // backgroundImage: NetworkImage(
                  //   currentUser.imageUrl ??
                  //       'https://example.com/default_avatar.png',
                  // ),
                  backgroundColor: currentUser.avatarColor,
                  radius: 20.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: '说点什么吧...',
                      hintStyle: TextStyle(color: AppColors.secondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () => _selectFiles(context),
              icon: const Icon(
                Icons.add_a_photo,
                color: AppColors.secondary,
              ),
              label: const Text(
                '选择图片',
                style: TextStyle(color: AppColors.secondary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deppBeige,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _selectedFiles.isEmpty
                  ? const Center(
                      child: Text('尚未选择图片'),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                      ),
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        return Stack(
                          children: [
                            Image.file(
                              file,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Positioned(
                              top: 4.0,
                              right: 4.0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFiles.removeAt(index);
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
