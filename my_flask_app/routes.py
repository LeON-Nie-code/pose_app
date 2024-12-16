import random
from flask import Blueprint, request, jsonify
from models import UserDetectionRecord, db, User, Post, bcrypt, VerificationCode,Todo,Friendship
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from datetime import timedelta,datetime
from werkzeug.utils import secure_filename
import base64
# from SendCode.send import SendCode

auth_bp = Blueprint('auth', __name__)


# auth_bp 中的新 API 端点
@auth_bp.route("/insert_record", methods=["POST"])
@jwt_required()
def insert_record():
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

    return jsonify({"message": "User registered successfully!"}), 201

# 用户注册
@auth_bp.route("/register", methods=["POST"])
def register():
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
    data = request.get_json()
    user = User.query.filter_by(email=data["email"]).first()
    if user and bcrypt.check_password_hash(user.password, data["password"]):
        access_token = create_access_token(identity=user.id, expires_delta=timedelta(hours=1))
        return jsonify(access_token=access_token)
    return jsonify({"message": "Invalid credentials"}), 401

# 使用手机号登录
@auth_bp.route("/login_phone", methods=["POST"])
def login_phone():
    data = request.get_json()
    user = User.query.filter_by(phone_number=data["phone_number"]).first()
    if user and bcrypt.check_password_hash(user.password, data["password"]):
        access_token = create_access_token(identity=user.id, expires_delta=timedelta(hours=1))
        return jsonify(access_token=access_token)
    return jsonify({"message": "Invalid credentials"}), 401

# 使用用户名登录
@auth_bp.route("/login_username", methods=["POST"])
def login_username():
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
    current_user_id = get_jwt_identity()
    print(f"Current User ID: {current_user_id}")  # 打印用户ID，检查是否正确提取
    user = User.query.get_or_404(current_user_id)
    return jsonify(username=user.username, email=user.email, id = user.id)

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

    return jsonify({"message": "Post created successfully!"}), 201


# 获取用户发布的所有帖子
@auth_bp.route("/posts", methods=["GET"])
@jwt_required()
def get_posts():
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)
    
    # 获取用户所有帖子
    posts = Post.query.filter_by(user_id=user.id).all()
    
    # 格式化帖子数据，包含图片的Base64编码
    post_list = []
    print("here is get post ")
    for post in posts:
        print(post.id)
        post_data = {
            "post_id": post.id,
            "title": post.title,
            "content": post.content,
            "date_posted": post.date_posted,
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

# 用户登出
@auth_bp.route("/logout", methods=["POST"])
@jwt_required()
def logout():
    # JWT 令牌无状态，因此这里只返回消息即可
    return jsonify({"message": "Successfully logged out"}), 200


# API to get user information
@auth_bp.route('/user_info', methods=['GET'])
@jwt_required()
def get_user():
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

# API to update user information
@auth_bp.route('/user_info', methods=['PUT'])
@jwt_required()
def update_user():
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    data = request.get_json()

    # Update fields if present in request data
    user.full_name = data.get('full_name', user.full_name)
    user.institution = data.get('institution', user.institution)
    user.gender = data.get('gender', user.gender)
    user.age = data.get('age', user.age)

    db.session.commit()
    return jsonify({'message': 'User updated successfully'}), 200


# API to add a new todo
@auth_bp.route('/user/todos', methods=['POST'])
@jwt_required()
def add_todo():
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


# API to get all todos for a user
@auth_bp.route('/user/todos', methods=['GET'])
@jwt_required()
def get_todos():
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    todos = Todo.query.filter_by(user_id=current_user_id).all()
    todo_list = [
        {
            'id': todo.id,
            'title': todo.title,
            'note': todo.note,
            'date': todo.date.isoformat(),
            'remind_time': todo.remind_time.isoformat() if todo.remind_time else None
        } for todo in todos
    ]

    return jsonify(todo_list), 200

# API to delete a todo
@auth_bp.route('/user/todos/<int:todo_id>', methods=['DELETE'])
@jwt_required()
def delete_todo(todo_id):
    current_user_id = get_jwt_identity()
    user = User.query.get_or_404(current_user_id)

    todo = Todo.query.get(todo_id)
    if not todo or todo.user_id != current_user_id:
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

    if current_user_id == friend_id:
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




@auth_bp.route("/")
def home():
    return "Hello, Flask!"


