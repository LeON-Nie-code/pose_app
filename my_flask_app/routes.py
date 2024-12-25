from flask import Blueprint, request, jsonify
from models import UserDetectionRecord, db, User, Post, bcrypt, VerificationCode,Todo,Friendship,Comment
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from datetime import timedelta,datetime
from werkzeug.utils import secure_filename
import base64
import random
import time
from sqlalchemy import func


# from SendCode.send import SendCode

auth_bp = Blueprint('auth', __name__)


# auth_bp 中的新 API 端点
@auth_bp.route("/insert_record", methods=["POST"])
@jwt_required()
def insert_record():
    """
    插入新的检测记录

    ---
    tags:
      - User Records
    summary: 插入新的检测记录
    description: 允许已认证用户插入一条新的检测记录，包括检测时长、开始时间、结束时间、坐姿次数和眼部活动次数。
    security:
      - Bearer: []
    requestBody:
      description: 检测记录的数据
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              duration:
                type: integer
                description: 检测时长（单位：秒）
              start_time:
                type: string
                format: date-time
                description: 检测的开始时间（ISO 8601 格式）
              end_time:
                type: string
                format: date-time
                description: 检测的结束时间（ISO 8601 格式）
              posture_times:
                type: integer
                description: 坐姿不良的次数
              eye_times:
                type: integer
                description: 眼部疲劳的次数
            required:
              - duration
              - start_time
              - end_time
              - posture_times
              - eye_times
    responses:
      201:
        description: 记录插入成功
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Record inserted successfully!"
      400:
        description: 请求数据缺少必填字段
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing required fields"
      404:
        description: 用户未找到
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "User not found"
    """
    print("Here is insert record")
    data = request.get_json()
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    

    # 验证请求中的数据
    required_fields = ["duration", "start_time", "end_time", "posture_times", "eye_times"]
    if not all(field in data for field in required_fields):
        return jsonify({"message": "Missing required fields"}), 400

    # 创建新的检测记录
    record = UserDetectionRecord(
        user_id=user.id,
        duration=data["duration"],
        start_time=data["start_time"],
        end_time=data["end_time"],
        posture_times=data["posture_times"],
        eye_times = data["eye_times"]
    )
    db.session.add(record)
    db.session.commit()

    return jsonify({"message": "Record inserted successfully!"}), 201

# 获取记录
@auth_bp.route("/records", methods=["GET"])
@jwt_required()
def get_records():
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)
    records = UserDetectionRecord.query.filter_by(user_id=user.id).all()
    return jsonify([{
        "duration": record.duration,
        "start_time": record.start_time,
        "end_time": record.end_time,
        "posture_times": record.posture_times,
        "eye_times": record.eye_times,
        "created_at": record.created_at
    } for record in records])


#用户注册，不使用验证码
@auth_bp.route("/register_no_code", methods=["POST"])
def register_no_code():
    """
    用户注册（不使用验证码）

    ---
    tags:
      - Authentication
    summary: 用户注册（无需验证码）
    description: 允许用户通过用户名、邮箱、密码和手机号进行注册，不使用验证码。
    requestBody:
      description: 用户注册所需信息
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              username:
                type: string
                description: 用户名
              email:
                type: string
                description: 邮箱地址
              password:
                type: string
                description: 用户密码
              phone_number:
                type: string
                description: 手机号码
    responses:
      201:
        description: 注册成功
      400:
        description: 用户已存在或其他错误
    """
    data = request.get_json()
    hashed_password = bcrypt.generate_password_hash(data["password"]).decode("utf-8")
    user = User(username=data["username"], email=data["email"], password=hashed_password, phone_number=data["phone_number"])
    user_get = User.query.filter_by(username=user.username).first()
    if user_get:
        return jsonify({"message": "User already exists"}), 400
    user_get = User.query.filter_by(email=user.email).first()
    if user_get:
        return jsonify({"message": "Email already exists"}), 400
    user_get = User.query.filter_by(phone_number=user.phone_number).first()
    if user_get:
        return jsonify({"message": "Phone number already exists"}), 400
    
    try:
        db.session.add(user)
        
        db.session.commit()
    except:
        return jsonify({"message": "User already exists!"}), 400

    # 添加新用户的详细信息到返回的JSON中
    response_data = {
        "message": "User registered successfully!",
        "username": user.username,
        "email": user.email,
        "phone_number": user.phone_number
    }
    return jsonify(response_data), 200

# 用户注册
@auth_bp.route("/register", methods=["POST"])
def register():
    """
    用户注册（使用验证码）

    ---
    tags:
      - Authentication
    summary: 用户注册（通过验证码验证）
    description: 用户通过手机号和验证码进行注册，注册成功后保存用户信息。
    requestBody:
      description: 用户注册信息与验证码
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              username:
                type: string
                description: 用户名
              email:
                type: string
                description: 邮箱地址
              password:
                type: string
                description: 用户密码
              phone_number:
                type: string
                description: 手机号码
              code:
                type: string
                description: 验证码
    responses:
      201:
        description: 注册成功
      400:
        description: 验证码错误或用户已存在
    """
    data = request.get_json()
    phone_number = data.get("phone_number")
    code = data.get("code")

    # 1. 验证手机号和验证码是否存在
    if not phone_number or not code:
        return jsonify({"message": "Phone number and code are required!"}), 400

    # 2. 检查验证码是否正确和是否过期
    verification_record = VerificationCode.query.filter_by(phone_number=phone_number).order_by(VerificationCode.created_at.desc()).first()
    print(verification_record)
    print(verification_record.is_expired())
    if not verification_record or verification_record.is_expired():
        return jsonify({"message": "Invalid or expired verification code."}), 400

    if verification_record.code != code:
        return jsonify({"message": "Incorrect verification code."}), 400

    # 3. 如果验证码验证通过，进行用户注册
    hashed_password = bcrypt.generate_password_hash(data["password"]).decode("utf-8")
    user = User(username=data["username"], email=data["email"], password=hashed_password, phone_number=phone_number)
    db.session.add(user)
    db.session.commit()

    return jsonify({"message": "User registered successfully!"}), 201

# 请求发送验证码
@auth_bp.route("/send_code", methods=["POST"])
def send_verification_code():
    """
    发送短信验证码

    ---
    tags:
      - Authentication
    summary: 发送验证码至用户手机
    description: 生成随机验证码，并发送至指定的手机号码。
    requestBody:
      description: 请求发送验证码的手机号
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              phone_number:
                type: string
                description: 用户手机号
    responses:
      200:
        description: 验证码发送成功
      400:
        description: 手机号格式错误
      500:
        description: 发送验证码失败
    """
    data = request.get_json()
    phone_number = data.get("phone_number")

    if not phone_number:
        return jsonify({"message": "Phone number is required!"}), 400

    # 生成6位验证码
    code = str(random.randint(1000, 9999))

    # # 保存验证码到数据库
    # verification_code = VerificationCode(phone_number=phone_number, code=code)
    # db.session.add(verification_code)
    # db.session.commit()

    # 发送短信验证码
    response = SendCode(code, phone_number)

    # 检查SendCode函数是否返回了None
    if response is None:
        # 如果返回None，则返回错误信息
        return jsonify({"error": "Failed to send verification code."}), 500

    # 检查响应的状态码
    if response['statusCode'] == 200:
        # 检查发送验证码是否成功
        if response['body']['Code'] == 'OK':
            # 保存验证码到数据库
            verification_code = VerificationCode(phone_number=phone_number, code=code)
            db.session.add(verification_code)
            db.session.commit()
            return jsonify({"message": "Verification code sent successfully!"}), 200
        else:
            # 处理手机号码格式错误的情况
            return jsonify({"error": response['body']['Message']}), 400
    else:
        # 处理其他可能的错误
        return jsonify({"error": "Failed to send verification code."}), 500
    
    



# 用户登录
@auth_bp.route("/login_email", methods=["POST"])
def login():
    """
    用户登录（通过邮箱）

    ---
    tags:
      - Authentication
    summary: 用户登录（使用邮箱）
    description: 用户通过邮箱和密码进行登录，成功后返回 JWT 令牌。
    requestBody:
      description: 登录所需的邮箱和密码
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              email:
                type: string
                description: 用户邮箱
              password:
                type: string
                description: 用户密码
    responses:
      200:
        description: 登录成功，返回访问令牌
      401:
        description: 登录失败，凭证无效
    """
    data = request.get_json()
    user = User.query.filter_by(email=data["email"]).first()
    if user and bcrypt.check_password_hash(user.password, data["password"]):
        access_token = create_access_token(identity=user.id, expires_delta=timedelta(hours=1))
        return jsonify(access_token=access_token)
    return jsonify({"message": "Invalid credentials"}), 401

# 使用手机号登录
@auth_bp.route("/login_phone", methods=["POST"])
def login_phone():
    """
    用户登录（通过手机号）

    ---
    tags:
      - Authentication
    summary: 用户登录（使用手机号）
    description: 用户通过手机号和密码进行登录，成功后返回 JWT 访问令牌。
    requestBody:
      description: 登录所需的手机号和密码
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              phone_number:
                type: string
                description: 用户的手机号
              password:
                type: string
                description: 用户的密码
            required:
              - phone_number
              - password
    responses:
      200:
        description: 登录成功，返回 JWT 访问令牌
        content:
          application/json:
            schema:
              type: object
              properties:
                access_token:
                  type: string
                  description: JWT 访问令牌
      401:
        description: 登录失败，凭证无效
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  description: 错误信息
    """
    data = request.get_json()
    user = User.query.filter_by(phone_number=data["phone_number"]).first()
    if user and bcrypt.check_password_hash(user.password, data["password"]):
        access_token = create_access_token(identity=user.id, expires_delta=timedelta(hours=1))
        return jsonify(access_token=access_token)
    return jsonify({"message": "Invalid credentials"}), 401

# 使用用户名登录
@auth_bp.route("/login_username", methods=["POST"])
def login_username():
    """
    用户登录（通过用户名）

    ---
    tags:
      - Authentication
    summary: 用户登录（使用用户名）
    description: 用户通过用户名和密码进行登录，成功后返回 JWT 访问令牌。
    requestBody:
      description: 登录所需的用户名和密码
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              username:
                type: string
                description: 用户的用户名
              password:
                type: string
                description: 用户的密码
            required:
              - username
              - password
    responses:
      200:
        description: 登录成功，返回 JWT 访问令牌
        content:
          application/json:
            schema:
              type: object
              properties:
                access_token:
                  type: string
                  description: JWT 访问令牌
      401:
        description: 登录失败，凭证无效
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  description: 错误信息
    """
    data = request.get_json()
    try:
        user = User.query.filter_by(username=data["username"]).first()
    except:
        return jsonify({"message": "Invalid credentials"}), 401
    if user and bcrypt.check_password_hash(user.password, data["password"]):
        access_token = create_access_token(identity=str(user.id), expires_delta=timedelta(hours=1))

        return jsonify(access_token=access_token)
    return jsonify({"message": "Invalid credentials"}), 401

# 获取当前用户信息
@auth_bp.route("/user", methods=["GET"])
@jwt_required()
def get_user_info():
    """
    获取当前用户信息

    ---
    tags:
      - User
    summary: 获取当前登录用户的信息
    description: 通过 JWT 访问令牌获取当前登录用户的基本信息（如用户名、邮箱和用户ID）。
    security:
      - Bearer: []
    responses:
      200:
        description: 返回用户的基本信息
        content:
          application/json:
            schema:
              type: object
              properties:
                username:
                  type: string
                  description: 用户的用户名
                email:
                  type: string
                  description: 用户的邮箱
                id:
                  type: integer
                  description: 用户的唯一标识符
      404:
        description: 用户不存在
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  description: 用户未找到的错误信息
    """
    current_user_id = get_jwt_identity()
    print(f"Current User ID: {current_user_id}")  # 打印用户ID，检查是否正确提取
    user = User.query.get_or_404(current_user_id)
    return jsonify(username=user.username, email=user.email, id = user.id, phone_number = user.phone_number)

# 发布帖子
# 发布帖子
# @auth_bp.route("/post", methods=["POST"])
# @jwt_required()
# def create_post():
#     data = request.get_json()
#     current_user_id = get_jwt_identity()
#     user = User.query.get_or_404(current_user_id)
    
#     title = data.get("title")
#     content = data.get("content")

#     # 创建帖子
#     post = Post(title=title, content=content, user_id=user.id)

#     # 处理图片上传
#     for i in range(1, 4):  # 最多三张照片
#         photo = request.files.get(f"photo{i}")
#         if photo:
#             photo_data = photo.read()  # 读取文件内容
#             setattr(post, f"photo{i}", photo_data)  # 将图像数据保存到相应字段

#     # 将帖子数据存储到数据库
#     db.session.add(post)
#     db.session.commit()

#     return jsonify({"message": "Post created successfully!"}), 201

@auth_bp.route("/post", methods=["POST"])
@jwt_required()
def create_post():
    """
    Create a new post with an optional image upload.

    This endpoint allows an authenticated user to create a post by providing
    a title, content, and up to 3 images. The user is identified through JWT,
    and the post is associated with the user's ID.

    **Request Body:**
    - title: string (required)
    - content: string (required)
    - photo1: file (optional)
    - photo2: file (optional)
    - photo3: file (optional)

    **Response:**
    - 201: Post created successfully.
    - 400: Invalid input or file type.

    ---
    tags:
      - Post
    responses:
      201:
        description: Post created successfully
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Post created successfully!"
      400:
        description: Bad Request - Missing or invalid data
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Bad Request"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    # 从表单数据中获取标题和内容
    title = request.form.get("title")
    content = request.form.get("content")

    # 创建帖子
    post = Post(title=title, content=content, user_id=user.id)

    # 处理图片上传
    for i in range(1, 4):  # 最多三张照片
        photo = request.files.get(f"photo{i}")
        if photo:
            photo_data = photo.read()  # 读取文件内容
            setattr(post, f"photo{i}", photo_data)  # 将图像数据保存到相应字段

    # 将帖子数据存储到数据库
    db.session.add(post)
    db.session.commit()

    # 帖子的id是
    return jsonify({"message": "Post created successfully!"}), 201



# # 获取用户发布的所有帖子
# @auth_bp.route("/posts", methods=["GET"])
# @jwt_required()
# def get_posts():
#     current_user_id = get_jwt_identity()
#     user = User.query.get_or_404(current_user_id)
    
#     # 获取用户所有帖子
#     posts = Post.query.filter_by(user_id=user.id).all()
    
#     # 格式化帖子数据，包含图片的Base64编码
#     post_list = []
#     print("here is get post ")
#     for post in posts:
#         print(post.id)
#         post_data = {
#             "post_id": post.id,
#             "title": post.title,
#             "content": post.content,
#             "date_posted": post.date_posted,
#             "likes":post.likes,
#             "comments":post.comments
#         }
        
#         # 处理图片字段，转换为Base64编码
#         for i in range(1, 4):  # 最多三张图片
#             photo_field = f"photo{i}"
#             photo_data = getattr(post, photo_field)
#             if photo_data:
#                 # 将二进制图像数据转换为Base64字符串
#                 encoded_photo = base64.b64encode(photo_data).decode('utf-8')
#                 post_data[f"photo{i}"] = f"data:image/jpeg;base64,{encoded_photo}"
        
#         post_list.append(post_data)
    
#     return jsonify(post_list)


@auth_bp.route("/posts", methods=["GET"])
@jwt_required()
def get_posts():
    """
    Get all posts created by the authenticated user, including images and comments.

    This endpoint retrieves all posts made by the currently authenticated user.
    It returns post details including title, content, date posted, number of likes, 
    and associated comments (with comment count and comment content).
    Additionally, any images attached to the posts are returned as Base64 encoded strings.

    **Response:**
    - 200: Successful response with posts data.

    ---
    tags:
      - Post
    responses:
      200:
        description: Successfully retrieved posts
        content:
          application/json:
            schema:
              type: array
              items:
                type: object
                properties:
                  post_id:
                    type: integer
                    example: 1
                  title:
                    type: string
                    example: "Sample Post Title"
                  content:
                    type: string
                    example: "This is the content of the post."
                  date_posted:
                    type: string
                    format: date-time
                    example: "2024-12-24T14:00:00"
                  likes:
                    type: integer
                    example: 10
                  comments_count:
                    type: integer
                    example: 3
                  comments:
                    type: array
                    items:
                      type: object
                      properties:
                        comment_id:
                          type: integer
                          example: 1
                        content:
                          type: string
                          example: "Great post!"
                        user_name:
                          type: string
                          example: "JohnDoe"
                        date_posted:
                          type: string
                          format: date-time
                          example: "2024-12-24T15:00:00"
                  photo1:
                    type: string
                    example: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAA..."
                  photo2:
                    type: string
                    example: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAA..."
                  photo3:
                    type: string
                    example: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAA..."
      401:
        description: Unauthorized - Authentication required
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)
    
    # 获取用户所有帖子
    posts = Post.query.filter_by(user_id=user.id).all()
    
    # 格式化帖子数据，包含图片的Base64编码和评论信息
    post_list = []
    print("here is get post ")
    for post in posts:
        print(post.id)
        
        # 获取该帖子的所有评论
        comments = Comment.query.filter_by(post_id=post.id).all()
        
        # 格式化评论信息（返回评论数量和评论内容）
        comment_list = []
        for comment in comments:
            comment_data = {
                "comment_id": comment.id,
                "content": comment.content,
                "user_name": comment.user_name if comment.user_name else "Anonymous",  # 如果没有用户名，使用 "Anonymous"
                "date_posted": comment.date_posted,
            }
            comment_list.append(comment_data)

        # 组织帖子数据
        post_data = {
            "post_id": post.id,
            "title": post.title,
            "content": post.content,
            "date_posted": post.date_posted,
            "likes": post.likes,
            "comments_count": len(comment_list),  # 返回评论数量
            "comments": comment_list,  # 返回评论内容
        }
        
        # 处理图片字段，转换为Base64编码
        for i in range(1, 4):  # 最多三张图片
            photo_field = f"photo{i}"
            photo_data = getattr(post, photo_field)
            if photo_data:
                # 将二进制图像数据转换为Base64字符串
                encoded_photo = base64.b64encode(photo_data).decode('utf-8')
                post_data[f"photo{i}"] = f"data:image/jpeg;base64,{encoded_photo}"
        
        post_list.append(post_data)
    
    return jsonify(post_list)



@auth_bp.route("/all_posts", methods=["GET"])
@jwt_required()
def get_all_posts():
    """
    Get all posts with pagination, including images and comments.

    This endpoint retrieves all posts with pagination. It returns post details including 
    title, content, date posted, number of likes, and associated comments (with comment 
    count and comment content). Additionally, any images attached to the posts are returned 
    as Base64 encoded strings.

    **Query Parameters:**
    - page: integer (optional, default: 1) - The page number to retrieve.
    - per_page: integer (optional, default: 10) - The number of posts per page.

    **Response:**
    - 200: Successful response with paginated posts data.

    ---
    tags:
      - Post
    parameters:
      - in: query
        name: page
        schema:
          type: integer
          example: 1
        description: The page number to retrieve.
      - in: query
        name: per_page
        schema:
          type: integer
          example: 10
        description: The number of posts per page.
    responses:
      200:
        description: Successfully retrieved posts with pagination
        content:
          application/json:
            schema:
              type: object
              properties:
                total_pages:
                  type: integer
                  example: 5
                current_page:
                  type: integer
                  example: 1
                posts:
                  type: array
                  items:
                    type: object
                    properties:
                      post_id:
                        type: integer
                        example: 1
                      title:
                        type: string
                        example: "Sample Post Title"
                      content:
                        type: string
                        example: "This is the content of the post."
                      date_posted:
                        type: string
                        format: date-time
                        example: "2024-12-24T14:00:00"
                      likes:
                        type: integer
                        example: 10
                      comments_count:
                        type: integer
                        example: 3
                      comments:
                        type: array
                        items:
                          type: object
                          properties:
                            comment_id:
                              type: integer
                              example: 1
                            content:
                              type: string
                              example: "Great post!"
                            user_name:
                              type: string
                              example: "JohnDoe"
                            date_posted:
                              type: string
                              format: date-time
                              example: "2024-12-24T15:00:00"
                      photo1:
                        type: string
                        example: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAA..."
                      photo2:
                        type: string
                        example: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAA..."
                      photo3:
                        type: string
                        example: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAA..."
      401:
        description: Unauthorized - Authentication required
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
    """
    # 获取查询参数，默认为第1页，每页10条帖子
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)

    # 获取所有帖子，分页
    posts = Post.query.order_by(Post.date_posted.desc()).paginate(page=page, per_page=per_page, error_out=False)

    # 格式化帖子数据，包含图片的Base64编码和评论信息
    post_list = []
    print("here is get post ")
    for post in posts.items:  # posts.items 包含当前页的帖子
        print(post.id)

        # 获取该帖子的所有评论
        comments = Comment.query.filter_by(post_id=post.id).all()

        # 格式化评论信息（返回评论数量和评论内容）
        comment_list = []
        for comment in comments:
            comment_data = {
                "comment_id": comment.id,
                "content": comment.content,
                "user_name": comment.user_name if comment.user_name else "Anonymous",  # 如果没有用户名，使用 "Anonymous"
                "date_posted": comment.date_posted,
            }
            comment_list.append(comment_data)

        # 组织帖子数据
        post_data = {
            "post_id": post.id,
            "title": post.title,
            "content": post.content,
            "date_posted": post.date_posted,
            "likes": post.likes,
            "comments_count": len(comment_list),  # 返回评论数量
            "comments": comment_list,  # 返回评论内容
        }

        # 处理图片字段，转换为Base64编码
        for i in range(1, 4):  # 最多三张图片
            photo_field = f"photo{i}"
            photo_data = getattr(post, photo_field)
            if photo_data:
                # 将二进制图像数据转换为Base64字符串
                encoded_photo = base64.b64encode(photo_data).decode('utf-8')
                post_data[f"photo{i}"] = f"data:image/jpeg;base64,{encoded_photo}"

        post_list.append(post_data)

    # 返回分页信息，包括总页数和当前页的帖子列表
    return jsonify({
        'total_pages': posts.pages,  # 总页数
        'current_page': posts.page,  # 当前页码
        'posts': post_list,  # 当前页的帖子数据
    }), 200


# # 获取所有用户发布的所有帖子
# @auth_bp.route("/all_posts", methods=["GET"])
# @jwt_required()
# def get_all_posts():
#     # 获取所有帖子
#     posts = Post.query.all()

#     # 格式化帖子数据，包含图片的Base64编码
    
      
#     # 格式化帖子数据，包含图片的Base64编码和评论信息
#     post_list = []
#     print("here is get post ")
#     for post in posts:
#         print(post.id)
        
#         # 获取该帖子的所有评论
#         comments = Comment.query.filter_by(post_id=post.id).all()
        
#         # 格式化评论信息（返回评论数量和评论内容）
#         comment_list = []
#         for comment in comments:
#             comment_data = {
#                 "comment_id": comment.id,
#                 "content": comment.content,
#                 "user_name": comment.user_name if comment.user_name else "Anonymous",  # 如果没有用户名，使用 "Anonymous"
#                 "date_posted": comment.date_posted,
#             }
#             comment_list.append(comment_data)

#         # 组织帖子数据
#         post_data = {
#             "post_id": post.id,
#             "title": post.title,
#             "content": post.content,
#             "date_posted": post.date_posted,
#             "likes": post.likes,
#             "comments_count": len(comment_list),  # 返回评论数量
#             "comments": comment_list,  # 返回评论内容
#         }
        
#         # 处理图片字段，转换为Base64编码
#         for i in range(1, 4):  # 最多三张图片
#             photo_field = f"photo{i}"
#             photo_data = getattr(post, photo_field)
#             if photo_data:
#                 # 将二进制图像数据转换为Base64字符串
#                 encoded_photo = base64.b64encode(photo_data).decode('utf-8')
#                 post_data[f"photo{i}"] = f"data:image/jpeg;base64,{encoded_photo}"
        
#         post_list.append(post_data)
    
#     return jsonify(post_list), 200


# 点赞帖子
@auth_bp.route("/post/<int:post_id>/like", methods=["POST"])
@jwt_required()
def like_post(post_id):
    """
    Like a post and increment the like count.

    This endpoint allows the authenticated user to like a specific post. 
    If the post's like count is `null`, it will be initialized to 0. 
    The like count will then be incremented by 1.

    **Path Parameters:**
    - post_id: integer (required) - The ID of the post to like.

    **Response:**
    - 200: Successfully liked the post with updated like count.

    ---
    tags:
      - Post
    parameters:
      - in: path
        name: post_id
        schema:
          type: integer
          example: 1
        required: true
        description: The ID of the post to like.
    responses:
      200:
        description: Successfully liked the post and returned updated like count.
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Post liked"
                likes:
                  type: integer
                  example: 11
      401:
        description: Unauthorized - Authentication required
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
      404:
        description: Post not found - The post with the given ID does not exist.
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Post not found"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    # 获取帖子
    post = Post.query.get_or_404(post_id)

    ## 检查 post.likes 是否为 null，如果是，则初始化为 0
    if post.likes is None:
        post.likes = 0
    # 增加点赞数
    post.likes += 1

    
    # 更新数据库
    db.session.commit()

    return jsonify({"message": "Post liked", "likes": post.likes}), 200




# 获取帖子的所有评论
@auth_bp.route("/post/<int:post_id>/comments", methods=["GET"])
@jwt_required()
def get_comments(post_id):
    """
    Get all comments for a specific post.

    This endpoint allows the authenticated user to retrieve all comments for a specific post. 
    It returns the list of comments including comment ID, content, date posted, user ID, and username.

    **Path Parameters:**
    - post_id: integer (required) - The ID of the post for which to retrieve comments.

    **Response:**
    - 200: Successfully retrieved comments for the specified post.

    ---
    tags:
      - Comment
    parameters:
      - in: path
        name: post_id
        schema:
          type: integer
          example: 1
        required: true
        description: The ID of the post to retrieve comments for.
    responses:
      200:
        description: Successfully retrieved comments for the specified post.
        content:
          application/json:
            schema:
              type: object
              properties:
                comments:
                  type: array
                  items:
                    type: object
                    properties:
                      id:
                        type: integer
                        example: 1
                      content:
                        type: string
                        example: "This is a comment."
                      date_posted:
                        type: string
                        format: date-time
                        example: "2024-12-24T15:00:00"
                      user_id:
                        type: integer
                        example: 101
                      username:
                        type: string
                        example: "JohnDoe"
      401:
        description: Unauthorized - Authentication required
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
      404:
        description: Post not found - The post with the given ID does not exist.
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Post not found"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    # 获取帖子
    post = Post.query.get_or_404(post_id)

    # 获取该帖子的所有评论
    comments = Comment.query.filter_by(post_id=post.id).all()
    result = []
    
    for comment in comments:
        result.append({
            "id": comment.id,
            "content": comment.content,
            "date_posted": comment.date_posted,
            "user_id": comment.user_id,
            "username": comment.user_name
        })

    return jsonify({"comments": result}), 200


# 添加评论
@auth_bp.route("/post/<int:post_id>/comment", methods=["POST"])
@jwt_required()
def add_comment(post_id):
    """
    Add a comment to a specific post.

    This endpoint allows the authenticated user to add a comment to a specific post. 
    The comment content is required, and it will be associated with the given post ID and the authenticated user.

    **Path Parameters:**
    - post_id: integer (required) - The ID of the post to add a comment to.

    **Request Body:**
    - content: string (required) - The content of the comment.

    **Response:**
    - 201: Successfully added the comment.
    - 400: Content is required.

    ---
    tags:
      - Comment
    parameters:
      - in: path
        name: post_id
        schema:
          type: integer
          example: 1
        required: true
        description: The ID of the post to add the comment to.
    requestBody:
      content:
        application/json:
          schema:
            type: object
            properties:
              content:
                type: string
                example: "This is a new comment."
            required:
              - content
    responses:
      201:
        description: Successfully added the comment to the specified post.
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Comment added"
                comment:
                  type: object
                  properties:
                    id:
                      type: integer
                      example: 1
                    content:
                      type: string
                      example: "This is a new comment."
                    date_posted:
                      type: string
                      format: date-time
                      example: "2024-12-24T16:00:00"
                    user_id:
                      type: integer
                      example: 101
      400:
        description: Bad Request - The content field is required.
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Content is required"
      401:
        description: Unauthorized - Authentication required
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
      404:
        description: Post not found - The post with the given ID does not exist.
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Post not found"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    # 获取帖子
    post = Post.query.get_or_404(post_id)

    # 获取请求数据
    data = request.get_json()
    content = data.get('content')

    if not content:
        return jsonify({"message": "Content is required"}), 400

    # 创建新评论
    comment = Comment(content=content, post_id=post.id, user_id=current_user_id, user_name=user.username)
    
    # 添加到数据库
    db.session.add(comment)
    db.session.commit()

    return jsonify({
        "message": "Comment added",
        "comment": {
            "id": comment.id,
            "content": comment.content,
            "date_posted": comment.date_posted,
            "user_id": comment.user_id
        }
    }), 201



# 删除评论
@auth_bp.route("/comment/<int:comment_id>", methods=["DELETE"])
@jwt_required()
def delete_comment(comment_id):
    """
    Delete a specific comment.

    This endpoint allows the authenticated user to delete their own comment from a specific post.
    Only the user who created the comment is allowed to delete it.

    **Path Parameters:**
    - comment_id: integer (required) - The ID of the comment to delete.

    **Response:**
    - 200: Successfully deleted the comment.
    - 403: Forbidden - The user is not authorized to delete this comment.
    - 404: Not Found - The comment with the given ID does not exist.

    ---
    tags:
      - Comment
    parameters:
      - in: path
        name: comment_id
        schema:
          type: integer
          example: 1
        required: true
        description: The ID of the comment to delete.
    responses:
      200:
        description: Successfully deleted the comment.
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Comment deleted successfully"
      403:
        description: Forbidden - You can only delete your own comments.
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "You can only delete your own comments"
      404:
        description: Not Found - The comment with the given ID does not exist.
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Comment not found"
      401:
        description: Unauthorized - Authentication required
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
    """
    current_user_id = get_jwt_identity()

    # 获取评论
    comment = Comment.query.get_or_404(comment_id)

    # 检查评论是否属于当前用户
    if comment.user_id != current_user_id:
        return jsonify({"message": "You can only delete your own comments"}), 403

    # 删除评论
    db.session.delete(comment)
    db.session.commit()

    return jsonify({"message": "Comment deleted successfully"}), 200





# 用户登出
@auth_bp.route("/logout", methods=["POST"])
@jwt_required()
def logout():
    # JWT 令牌无状态，因此这里只返回消息即可
    return jsonify({"message": "Successfully logged out"}), 200


# 获取用户信息
@auth_bp.route('/user_info', methods=['GET'])
@jwt_required()
def get_user():
    """
    获取当前用户信息。

    该接口允许认证用户获取自己的个人信息。返回的信息包括用户的ID、用户名、电子邮件、手机号、全名、所属机构、性别和年龄。

    **响应:**
    - 200: 成功返回用户信息。

    ---
    tags:
      - 用户信息
    responses:
      200:
        description: 成功返回用户信息。
        content:
          application/json:
            schema:
              type: object
              properties:
                id:
                  type: integer
                  example: 1
                username:
                  type: string
                  example: "li_lei"
                email:
                  type: string
                  example: "li_lei@example.com"
                phone_number:
                  type: string
                  example: "13800000000"
                full_name:
                  type: string
                  example: "李雷"
                institution:
                  type: string
                  example: "北京大学"
                gender:
                  type: string
                  example: "男"
                age:
                  type: integer
                  example: 25
      401:
        description: 未授权 - 需要身份验证。
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    user_info = {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'phone_number': user.phone_number,
        'full_name': user.full_name,
        'institution': user.institution,
        'gender': user.gender,
        'age': user.age
    }
    return jsonify(user_info), 200


# 更新用户信息
@auth_bp.route('/user_info', methods=['PUT'])
@jwt_required()
def update_user():
    """
    更新用户信息。

    该接口允许认证用户更新自己的个人信息。用户可以更新的字段包括全名、所属机构、性别和年龄。请求数据中可以只包含部分字段，未包含的字段将保持原有值。

    **请求体参数:**
    - full_name: string (可选) - 用户的全名。
    - institution: string (可选) - 用户所属的机构。
    - gender: string (可选) - 用户的性别。
    - age: integer (可选) - 用户的年龄。

    **响应:**
    - 200: 成功更新用户信息。
    - 400: 请求数据无效。

    ---
    tags:
      - 用户信息
    requestBody:
      content:
        application/json:
          schema:
            type: object
            properties:
              full_name:
                type: string
                example: "李雷"
              institution:
                type: string
                example: "北京大学"
              gender:
                type: string
                example: "男"
              age:
                type: integer
                example: 25
    responses:
      200:
        description: 成功更新用户信息。
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "User updated successfully"
      400:
        description: 请求数据无效。
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Invalid request data"
      401:
        description: 未授权 - 需要身份验证。
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    data = request.get_json()

    # 更新字段，如果请求数据中存在相应字段
    user.full_name = data.get('full_name', user.full_name)
    user.institution = data.get('institution', user.institution)
    user.gender = data.get('gender', user.gender)
    user.age = data.get('age', user.age)
    

    db.session.commit()
    print("after commit", user.full_name)
    return jsonify({'message': 'User updated successfully'}), 200


@auth_bp.route("/users/top-durations", methods=["GET"])
@jwt_required()
def get_top_users_by_duration():
    # 获取当前用户 ID
    current_user_id = get_jwt_identity()

    # 验证当前用户是否存在
    user = User.query.get_or_404(current_user_id)

    # 查询所有用户的检测持续时间总和，按照总和降序排序，限制前 20 名
    top_users = (
        db.session.query(
            User.username,
            func.sum(UserDetectionRecord.duration).label('total_duration')
        )
        .join(UserDetectionRecord, User.id == UserDetectionRecord.user_id)
        .group_by(User.id)
        .order_by(func.sum(UserDetectionRecord.duration).desc())
        .limit(20)
        .all()
    )

    # 将结果转为排名格式
    result = [
        {
            "rank": idx + 1,
            "username": user.username,
            "total_duration": round(user.total_duration, 2)
        }
        for idx, user in enumerate(top_users)
    ]

    return jsonify({"message": "Top users by detection duration", "data": result}), 200



# 添加新的待办事项
@auth_bp.route('/user/todos', methods=['POST'])
@jwt_required()
def add_todo():
    """
    添加新的待办事项。

    该接口允许认证用户添加一个新的待办事项。请求数据中必须包含标题和日期，其他字段是可选的（如备注和提醒时间）。

    **请求体参数:**
    - title: string (必填) - 待办事项的标题。
    - date: string (必填) - 待办事项的日期，ISO 8601 格式（例如："2024-12-25T10:00:00"）。
    - note: string (可选) - 待办事项的备注信息。
    - remind_time: string (可选) - 提醒时间，ISO 8601 格式（例如："2024-12-25T09:30:00"）。

    **响应:**
    - 201: 成功添加待办事项。
    - 400: 请求数据无效，标题和日期是必填字段。

    ---
    tags:
      - 待办事项
    requestBody:
      content:
        application/json:
          schema:
            type: object
            properties:
              title:
                type: string
                example: "完成作业"
              date:
                type: string
                format: date-time
                example: "2024-12-25T10:00:00"
              note:
                type: string
                example: "按时提交"
              remind_time:
                type: string
                format: date-time
                example: "2024-12-25T09:30:00"
    responses:
      201:
        description: 成功添加待办事项。
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Todo added successfully"
      400:
        description: 请求数据无效，标题和日期是必填字段。
        content:
          application/json:
            schema:
              type: object
              properties:
                error:
                  type: string
                  example: "Title and date are required"
      401:
        description: 未授权 - 需要身份验证。
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    data = request.get_json()
    title = data.get('title')
    date = data.get('date')

    if not title or not date:
        return jsonify({'error': 'Title and date are required'}), 400

    note = data.get('note')
    remind_time = data.get('remind_time')

    todo = Todo(user_id=current_user_id, title=title, note=note, date=datetime.fromisoformat(date), remind_time=datetime.fromisoformat(remind_time) if remind_time else None)
    db.session.add(todo)
    db.session.commit()

    return jsonify({'message': 'Todo added successfully'}), 201



# 获取用户的所有待办事项
@auth_bp.route('/user/todos', methods=['GET'])
@jwt_required()
def get_todos():
    """
    获取当前用户的所有待办事项。

    该接口允许认证用户获取自己的所有待办事项。返回的每个待办事项包含标题、备注、日期和提醒时间。

    **响应数据格式:**
    - id: 待办事项的ID。
    - user_id: 用户名。
    - title: 待办事项的标题。
    - note: 待办事项的备注。
    - date: 待办事项的日期，ISO 8601 格式（例如："2024-12-25T10:00:00"）。
    - remind_time: 提醒时间，ISO 8601 格式（例如："2024-12-25T09:30:00"），如果没有提醒时间，则为 `null`。

    **响应:**
    - 200: 成功获取待办事项。

    ---
    tags:
      - 待办事项
    responses:
      200:
        description: 成功获取待办事项。
        content:
          application/json:
            schema:
              type: array
              items:
                type: object
                properties:
                  id:
                    type: integer
                    example: 1
                  user_id:
                    type: string
                    example: "john_doe"
                  title:
                    type: string
                    example: "完成作业"
                  note:
                    type: string
                    example: "按时提交"
                  date:
                    type: string
                    format: date-time
                    example: "2024-12-25T10:00:00"
                  remind_time:
                    type: string
                    format: date-time
                    example: "2024-12-25T09:30:00"
                  nullable: true
      401:
        description: 未授权 - 需要身份验证。
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    current_user_name = user.username

    print('user_name in todo: ', current_user_name)

    todos = Todo.query.filter_by(user_id=current_user_id).all()
    todo_list = [
        {
            'id': todo.id,
            'user_id': current_user_name,
            'title': todo.title,
            'note': todo.note,
            'date': todo.date.isoformat(),
            'remind_time': todo.remind_time.isoformat() if todo.remind_time else None
        } for todo in todos
    ]

    return jsonify(todo_list), 200


# 删除待办事项
@auth_bp.route('/user/todos/<int:todo_id>', methods=['DELETE'])
@jwt_required()
def delete_todo(todo_id):
    """
    删除指定的待办事项。

    该接口允许用户删除自己创建的待办事项。请求中的 `todo_id` 必须是用户的待办事项ID，且该待办事项必须属于当前用户。如果待办事项不存在或不属于当前用户，将返回404错误。

    **响应数据格式:**
    - message: 操作结果信息，删除成功则为 "Todo deleted successfully"。

    **响应:**
    - 200: 成功删除待办事项。
    - 404: 待办事项未找到或不属于当前用户。
    
    ---
    tags:
      - 待办事项
    parameters:
      - in: path
        name: todo_id
        required: true
        description: 待办事项ID
        schema:
          type: integer
          example: 1
    responses:
      200:
        description: 成功删除待办事项。
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Todo deleted successfully"
      404:
        description: 待办事项未找到或不属于当前用户。
        content:
          application/json:
            schema:
              type: object
              properties:
                error:
                  type: string
                  example: "Todo not found or does not belong to the user"
      401:
        description: 未授权 - 需要身份验证。
        content:
          application/json:
            schema:
              type: object
              properties:
                message:
                  type: string
                  example: "Missing or invalid token"
    """
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    todo = Todo.query.get(todo_id)
    if not todo or todo.user_id != int(current_user_id):
        return jsonify({'error': 'Todo not found or does not belong to the user'}), 404

    db.session.delete(todo)
    db.session.commit()

    return jsonify({'message': 'Todo deleted successfully'}), 200




@auth_bp.route('/friend/request', methods=['POST'])
@jwt_required()
def send_friend_request():
    current_user_id = get_jwt_identity()  # 获取当前用户 ID
    user = User.query.get_or_404(current_user_id)

    data = request.json
    friend_id = data.get('friend_id')

    if not friend_id:
        return jsonify({'error': 'Friend ID is required'}), 400

    if int(current_user_id) == friend_id:
        return jsonify({'error': 'Cannot add yourself as a friend'}), 400

    # 检查是否已有好友请求或是好友
    existing_request = Friendship.query.filter_by(user_id=current_user_id, friend_id=friend_id).first()
    if existing_request:
        return jsonify({'error': 'Friend request already sent or you are already friends'}), 400

    friendship = Friendship(user_id=current_user_id, friend_id=friend_id)
    db.session.add(friendship)
    db.session.commit()

    return jsonify({'message': 'Friend request sent successfully'}), 200


@auth_bp.route('/friend/request/<int:request_id>', methods=['PUT'])
@jwt_required()
def respond_to_friend_request(request_id):
    current_user_id = get_jwt_identity()  # 获取当前用户 ID
    user = User.query.get_or_404(current_user_id)

    data = request.json
    action = data.get('action')  # accept 或 reject

    friendship = Friendship.query.get_or_404(request_id)
    
    print("user_id:", current_user_id)
    print(type(current_user_id))
    print("friend_id:", friendship.friend_id)
    print(type(friendship.friend_id))

    if friendship.friend_id != int(current_user_id):
        return jsonify({'error': 'You are not authorized to respond to this friend request'}), 403

    if action == 'accept':
        friendship.status = 'accepted'
        db.session.commit()
        return jsonify({'message': 'Friend request accepted'}), 200
    elif action == 'reject':
        db.session.delete(friendship)
        db.session.commit()
        return jsonify({'message': 'Friend request rejected'}), 200
    else:
        return jsonify({'error': 'Invalid action'}), 400


@auth_bp.route('/friends', methods=['GET'])
@jwt_required()
def get_friends():
    current_user_id = get_jwt_identity()  # 获取当前用户 ID
    user = User.query.get_or_404(current_user_id)

    friends = Friendship.query.filter(
        ((Friendship.user_id == current_user_id) | (Friendship.friend_id == current_user_id)) &
        (Friendship.status == 'accepted')
    ).all()

    friend_list = []
    for friend in friends:
        friend_id = friend.friend_id if friend.user_id == current_user_id else friend.user_id
        friend_user = User.query.get(friend_id)
        friend_list.append({'id': friend_user.id, 'username': friend_user.username})

    return jsonify(friend_list), 200


@auth_bp.route('/friend/<int:friend_id>', methods=['DELETE'])
@jwt_required()
def delete_friend(friend_id):
    current_user_id = get_jwt_identity()  # 获取当前用户 ID
    user = User.query.get_or_404(current_user_id)

    friendship = Friendship.query.filter(
        ((Friendship.user_id == current_user_id) & (Friendship.friend_id == friend_id)) |
        ((Friendship.user_id == friend_id) & (Friendship.friend_id == current_user_id))
    ).first()

    if not friendship:
        return jsonify({'error': 'Friendship not found'}), 404

    db.session.delete(friendship)
    db.session.commit()
    return jsonify({'message': 'Friend deleted successfully'}), 200


@auth_bp.route('/friend/status/<int:friend_id>', methods=['GET'])
@jwt_required()
def check_friend_status(friend_id):
    current_user_id = get_jwt_identity()  # 获取当前用户 ID
    user = User.query.get_or_404(current_user_id)

    friendship = Friendship.query.filter(
        ((Friendship.user_id == current_user_id) & (Friendship.friend_id == friend_id)) |
        ((Friendship.user_id == friend_id) & (Friendship.friend_id == current_user_id))
    ).first()

    if not friendship:
        return jsonify({'status': 'none'}), 200
    return jsonify({'status': friendship.status}), 200

@auth_bp.route('/friend/requests/received', methods=['GET'])
@jwt_required()
def get_received_friend_requests():
    current_user_id = get_jwt_identity()  # 获取当前用户 ID

    # 查询别人发给当前用户的好友请求
    received_requests = Friendship.query.filter_by(friend_id=current_user_id, status='pending').all()

    # 构造返回的 JSON
    result = []
    for request in received_requests:
        sender = User.query.get(request.user_id)
        result.append({
            'request_id': request.id,
            'sender_id': sender.id,
            'sender_username': sender.username,
            'created_at': request.created_at.isoformat()
        })

    return jsonify(result), 200

@auth_bp.route('/friend/requests/sent', methods=['GET'])
@jwt_required()
def get_sent_friend_requests():
    current_user_id = get_jwt_identity()  # 获取当前用户 ID

    # 查询当前用户发给别人的好友请求
    sent_requests = Friendship.query.filter_by(user_id=current_user_id, status='pending').all()

    # 构造返回的 JSON
    result = []
    for request in sent_requests:
        receiver = User.query.get(request.friend_id)
        result.append({
            'request_id': request.id,
            'receiver_id': receiver.id,
            'receiver_username': receiver.username,
            'created_at': request.created_at.isoformat()
        })

    return jsonify(result), 200




def normalize_ratios(ratios):
     # 确保所有的值都是数字类型
    for key, value in ratios.items():
        if not isinstance(value, (int, float)):
            raise ValueError(f"Value for {key} is not a number: {value}")
    # print(ratios)
    sum_original = sum(ratios.values())
    # 归一化比例，使得它们的和为1
    for key, value in ratios.items():
        ratios[key] = value / sum_original

    # print(ratios)
    return ratios

def allocate_duration_eye(duration):
    eye_times = {
        "Looking at screen": round(random.uniform(20, 60), 4),
        "Not looking at screen": round(random.uniform(10, 40), 4),
    }

    # 归一化比例
    normalized_eye_times = normalize_ratios(eye_times)

    # 分配duration到各个姿势
    allocated_times = {}
    for eye_status, ratio in normalized_eye_times.items():
        # 计算每个姿势的时间
        allocated_time = ratio * duration
        allocated_times[eye_status] = round(allocated_time, 4)

    # 添加session_duration和total
    allocated_times["session_duration"] = round(duration, 4)
    allocated_times["total"] = sum(allocated_times.values())

    return allocated_times        

def allocate_duration(duration):
    # 定义姿势及其随机初始比例
    postures = {
        "bow": random.uniform(0.01, 0.05),
        "left tilt": random.uniform(0.01, 0.05),
        "looking up": random.uniform(0.01, 0.05),
        "lying down in the chair": random.uniform(0.01, 0.05),
        "normal": random.uniform(0.01, 0.05),
        "right tilt": random.uniform(0.01, 0.05),
        "left face": random.uniform(0.01, 0.05),
        "right face": random.uniform(0.01, 0.05),
        "high shoulder": random.uniform(0.01, 0.05),
        "low shoulder": random.uniform(0.01, 0.05),
        "supporting the table": random.uniform(0.01, 0.05),
    }
    
    # 归一化比例
    normalized_postures = normalize_ratios(postures)
    
    # 分配duration到各个姿势
    allocated_times = {}
    for posture, ratio in normalized_postures.items():
        # 计算每个姿势的时间
        allocated_time = ratio * duration
        allocated_times[posture] = round(allocated_time, 4)
    
    # 添加session_duration和total
    allocated_times["session_duration"] = round(duration, 4)
    allocated_times["total"] = sum(allocated_times.values())
    
    return allocated_times



@auth_bp.route('/random_session_data/<int:duration>', methods=['GET'])
def random_session_data(duration):
    # 获取当前时间戳（秒）
    end_time = time.time()
    
    # 随机生成duration，范围可以根据实际情况调整
    duration = duration
    
    # 计算start_time
    start_time = end_time - duration
    
    # 随机生成posture_times数据
    posture_times = allocate_duration(duration)

    posture_times["total"] = posture_times["total"] - posture_times["session_duration"]
    
    # 随机生成eye_times数据
    eye_times = allocate_duration_eye(duration)
    
    eye_times["total"] = int(eye_times["total"] - eye_times["session_duration"])

    
    # 构造响应数据
    response_data = {
        "duration": duration,
        "start_time": start_time,
        "end_time": end_time,
        "posture_times": posture_times,
        "eye_times": eye_times
    }
    
    # 返回JSON响应
    return jsonify(response_data)




@auth_bp.route("/")
def home():
    return "Hello, Flask!"


