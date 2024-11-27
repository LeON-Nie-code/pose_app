// 模拟数据文件，定义用户(User)和帖子(Post)的模型及其数据
//// 提供静态数据，用于前端展示，后续将由后端数据替换
///
///// TODO: 后端需要提供以下数据结构接口：
// - 用户信息接口：包括用户名、头像路径
// - 帖子列表接口：包括帖子内容、图片路径、发布时间、点赞数、评论数、转发数

class User {
  final String name;
  final String? imageUrl;
  final String? assetImage;

  const User({
    required this.name,
    this.imageUrl,
    this.assetImage,
  });
}

class Post {
  final User user;
  final String caption;
  final String timeAgo;
  final List<String>? imageUrls; // 多个网络图片路径
  final List<String>? assetImages; // 多个本地图片路径
  final int likes;
  final int comments;
  final int shares;

  const Post({
    required this.user,
    required this.caption,
    required this.timeAgo,
    this.imageUrls,
    this.assetImages,
    required this.likes,
    required this.comments,
    required this.shares,
  });
}

// 数据定义
// TODO: 替换为从后端 API 获取的当前用户信息
final User currentUser = User(
  name: 'User1',
  imageUrl:
      'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRIy7a_ku4Wciy5AfV7pyjiX2cBWpcdVfad4HsvKJjMFBy5T53pJW-HiVZeaMXky2-7B6c96TNwyhuiY48guQ7rog',
);

final List<User> onlineUsers = [
  User(
    name: 'User2',
    imageUrl:
        'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRIy7a_ku4Wciy5AfV7pyjiX2cBWpcdVfad4HsvKJjMFBy5T53pJW-HiVZeaMXky2-7B6c96TNwyhuiY48guQ7rog',
  ),
  User(
    name: 'User3',
    imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdY38b13sLgNh8HhJoTPS5JsvNBirQ5gzauA&s',
  ),
];
// TODO: 替换为从后端 API 获取的帖子列表
final List<Post> posts = [
  Post(
    user: currentUser,
    caption: '内容11111',
    timeAgo: '58m',
    imageUrls: [
      'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRIy7a_ku4Wciy5AfV7pyjiX2cBWpcdVfad4HsvKJjMFBy5T53pJW-HiVZeaMXky2-7B6c96TNwyhuiY48guQ7rog',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdY38b13sLgNh8HhJoTPS5JsvNBirQ5gzauA&s',
    ],
    likes: 1202,
    comments: 184,
    shares: 96,
  ),
  Post(
    user: onlineUsers[1],
    caption: '内容33333',
    timeAgo: '3hr',
    imageUrls: [
      'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRIy7a_ku4Wciy5AfV7pyjiX2cBWpcdVfad4HsvKJjMFBy5T53pJW-HiVZeaMXky2-7B6c96TNwyhuiY48guQ7rog',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdY38b13sLgNh8HhJoTPS5JsvNBirQ5gzauA&s',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTK3uu45UWvHLN6-4kjP9lfUIv0MzXiEEgNeQ&s',
    ],
    likes: 683,
    comments: 79,
    shares: 18,
  ),
];
