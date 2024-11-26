import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pose_app/Community/dataAboutCommunity.dart';
import 'package:pose_app/style/colors.dart';



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
          newFiles.where((newFile) =>
              !_selectedFiles.any((existingFile) => existingFile.path == newFile.path)),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未选择图片')),
      );
    }
  }

  // 提交帖子
  void _submitPost() {
    if (_descriptionController.text.isNotEmpty && _selectedFiles.isNotEmpty) {
      
      // TODO: 调用后端图片上传接口，将图片文件上传到后端并获取 URL
      // 示例：List<String> imageUrls = await uploadImagesToServer(_selectedFiles);

      
      final newPost = Post(
        user: currentUser,
        caption: _descriptionController.text,
        timeAgo: '刚刚',
        imageUrls: null,
        assetImages: _selectedFiles.map((file) => file.path).toList(), // 存储多个本地路径
        likes: 0,
        comments: 0,
        shares: 0,
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
            icon: const Icon(Icons.send, color: AppColors.secondary,),
            label: const Text(
              '发布',
              style: TextStyle(color: AppColors.secondary),),
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
                  backgroundImage: NetworkImage(
                    currentUser.imageUrl ??
                        'https://example.com/default_avatar.png',
                  ),
                  radius: 20.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: '说点什么吧...',
                      hintStyle: TextStyle(color: AppColors.secondary ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () => _selectFiles(context),
              icon: const Icon(Icons.add_a_photo, color: AppColors.secondary,),
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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