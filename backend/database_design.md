## 数据库名称

pose_app_db
## 表设计
### 1. 用户表（users）

存储用户的基本信息。

```sql
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY, 
    username VARCHAR(50) NOT NULL UNIQUE, 
    email VARCHAR(100) NOT NULL UNIQUE, 
    password_hash VARCHAR(255) NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 2. 好友关系表（friends）

存储用户之间的好友关系。
```sql
CREATE TABLE friends (
    user_id INT NOT NULL, 
    friend_id INT NOT NULL, 
    status ENUM('pending', 'accepted', 'blocked') DEFAULT 'pending', 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    PRIMARY KEY (user_id, friend_id), 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE, 
    FOREIGN KEY (friend_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```


### 3. 帖子表（posts）

存储用户的帖子信息。

```sql
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY, 
    user_id INT NOT NULL, 
    content TEXT NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```
### 4. 帖子图片表（post_images）

存储每个帖子的图片信息。

```sql
CREATE TABLE post_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY, 
    post_id INT NOT NULL, 
    image_url VARCHAR(255) NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);
```


### 5. 评论表（comments）

存储帖子评论。

```sql
CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY, 
    post_id INT NOT NULL, 
    user_id INT NOT NULL, 
    content TEXT NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE, 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

### 6. 点赞表（likes）

存储用户对帖子或评论的点赞信息。

```sql
CREATE TABLE likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY, 
    target_id INT NOT NULL, -- 可指向 posts 或 comments 的 ID
    target_type ENUM('post', 'comment') NOT NULL, 
    user_id INT NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    UNIQUE (target_id, target_type, user_id), 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

### 7. 姿势检测记录表（posture_records）

存储用户每次检测的姿势记录。

```sql
CREATE TABLE posture_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY, 
    user_id INT NOT NULL, 
    start_time DATETIME NOT NULL, 
    end_time DATETIME NOT NULL, 
    normal_time INT NOT NULL, -- 单位：秒
    left_tilt_time INT NOT NULL, 
    right_tilt_time INT NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

### 8. 每日统计表（daily_statistics）

存储用户每天的检测统计数据。

```sql
CREATE TABLE daily_statistics (
    stat_id INT AUTO_INCREMENT PRIMARY KEY, 
    user_id INT NOT NULL, 
    date DATE NOT NULL, 
    total_normal_time INT NOT NULL, 
    total_left_tilt_time INT NOT NULL, 
    total_right_tilt_time INT NOT NULL, 
    total_sessions INT NOT NULL, -- 总检测次数
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    UNIQUE (user_id, date), 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

### 9. 摄像头记录表（camera_logs）

存储用户选择的摄像头日志。

```sql
CREATE TABLE camera_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY, 
    user_id INT NOT NULL, 
    camera_index INT NOT NULL, 
    selected_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

## 数据库设计特点

### 1.用户功能：
- 用户信息通过 users 表管理。
- 好友关系通过 friends 表实现，包括好友请求状态。

###  2.社交功能：
- 帖子、评论、点赞通过 posts、comments 和 likes 表分别管理。
- 支持对帖子和评论进行点赞。

### 3.姿势检测记录和统计：
- 每次检测的详细记录存储在 posture_records 表。
- 按日期统计的检测数据存储在 daily_statistics 表。

### 4.摄像头日志：
- 用户的摄像头选择记录存储在 camera_logs 表。

## 查询示例

### 1.获取用户的好友列表：

```sql
SELECT u.username 
FROM users u 
JOIN friends f ON u.user_id = f.friend_id 
WHERE f.user_id = ? AND f.status = 'accepted';
```
### 2.获取用户的检测统计（今天）：

```sql
SELECT * 
FROM daily_statistics 
WHERE user_id = ? AND date = CURDATE();
```

### 3.获取某帖子的评论及点赞数：

```sql
SELECT c.comment_id, c.content, COUNT(l.like_id) AS like_count 
FROM comments c 
LEFT JOIN likes l ON c.comment_id = l.target_id AND l.target_type = 'comment' 
WHERE c.post_id = ? 
GROUP BY c.comment_id;
```


### 4.获取帖子及其图片：

```sql
SELECT p.post_id, p.content, i.image_url 
FROM posts p 
LEFT JOIN post_images i ON p.post_id = i.post_id 
WHERE p.post_id = ?;
```

### 5.获取用户所有的帖子及图片：

```sql
SELECT p.post_id, p.content, i.image_url 
FROM posts p 
LEFT JOIN post_images i ON p.post_id = i.post_id 
WHERE p.user_id = ? 
ORDER BY p.created_at DESC;
```