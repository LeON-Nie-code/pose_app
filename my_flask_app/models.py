from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from datetime import datetime, timedelta
import pytz

db = SQLAlchemy()
bcrypt = Bcrypt()

# 定义 GMT+8 时区
gmt8 = pytz.timezone('Asia/Shanghai')

class UserDetectionRecord(db.Model):
    __tablename__ = 'user_detection_records'  # 定义表名
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    duration = db.Column(db.Float, nullable=False)  # 检测持续时间（秒）
    start_time = db.Column(db.Integer, nullable=False)  # 检测开始时间（Unix时间戳）
    end_time = db.Column(db.Integer, nullable=False)  # 检测结束时间（Unix时间戳）
    posture_times = db.Column(db.JSON, nullable=False)  # 各种姿势的持续时间
    eye_times = db.Column(db.JSON, nullable=True)   # 各种眼睛状态的持续时间
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(gmt8))  # 记录创建时间

    user = db.relationship('User', backref=db.backref('detection_records', lazy=True))

    def __repr__(self):
        return f"UserDetectionRecord('{self.user_id}', '{self.start_time}', '{self.end_time}', '{self.created_at}')"

class VerificationCode(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    phone_number = db.Column(db.String(15), nullable=False)
    code = db.Column(db.String(6), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(gmt8))

    def is_expired(self):
        return datetime.now(gmt8) > self.created_at + timedelta(minutes=5)  # 验证码5分钟过期

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=True)
    password = db.Column(db.String(60), nullable=False)
    posts = db.relationship('Post', backref='author', lazy=True)
    phone_number = db.Column(db.String(11), unique=True, nullable=False)

    # detection_records = db.relationship('UserDetectionRecord', backref='user', lazy=True)

    # New fields
    full_name = db.Column(db.String(100), nullable=True)  # Full name
    institution = db.Column(db.String(200), nullable=True)  # Institution
    gender = db.Column(db.String(10), nullable=True)  # Gender
    age = db.Column(db.Integer, nullable=True)  # Age

    todos = db.relationship('Todo', backref='user', lazy=True)


    def __repr__(self):
        return f"User('{self.username}', '{self.email}')"

class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    content = db.Column(db.Text, nullable=False)
    date_posted = db.Column(db.DateTime, default=lambda: datetime.now(gmt8))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    # 添加最多三张图片的字段，类型为 BLOB
    photo1 = db.Column(db.LargeBinary, nullable=True)  # 第一张照片
    photo2 = db.Column(db.LargeBinary, nullable=True)  # 第二张照片
    photo3 = db.Column(db.LargeBinary, nullable=True)  # 第三张照片

    likes = db.Column(db.Integer, default=0)  # 点赞数
    comments = db.Column(db.JSON, default=list)  # 评论列表，存储为 JSON 格式


    def __repr__(self):
        return f"Post('{self.title}', '{self.date_posted}', '{self.id}')"

# 新建一个 Comment 模型
class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)  # 评论内容
    date_posted = db.Column(db.DateTime, default=lambda: datetime.now(gmt8))  # 评论时间
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)  # 评论的用户
    post_id = db.Column(db.Integer, db.ForeignKey('post.id'), nullable=False)  # 关联的文章
    user_name = db.Column(db.Text, nullable=True)

    # 通过外键关系定义与 Post 和 User 的关系
    # post = db.relationship('Post', backref=db.backref('comments', lazy=True))  # 评论与文章的关联
    user = db.relationship('User', backref=db.backref('comments', lazy=True))  # 评论与用户的关联

    def __repr__(self):
        return f"Comment('{self.content}', '{self.date_posted}')"

class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    title = db.Column(db.String(100), nullable=False)  # Todo title
    note = db.Column(db.Text, nullable=True)  # Todo note
    date = db.Column(db.DateTime, nullable=False)  # Todo date
    remind_time = db.Column(db.DateTime, nullable=True)  # Reminder time

    def __repr__(self):
        return f"Todo('{self.title}', '{self.date}')"

class Friendship(db.Model):
    __tablename__ = 'friendships'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    friend_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    status = db.Column(db.String(20), nullable=False, default='pending')  # pending, accepted, blocked
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(gmt8))

    user = db.relationship('User', foreign_keys=[user_id], backref=db.backref('friendships', lazy=True))
    friend = db.relationship('User', foreign_keys=[friend_id])

    def __repr__(self):
        return f"Friendship('{self.user_id}', '{self.friend_id}', '{self.status}')"
