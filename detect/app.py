import cv2
from flask import Flask, jsonify, request, Response
import mediapipe as mp
from flask_cors import CORS
import threading
import math
from detect.utils import all_detection

app = Flask(__name__)
CORS(app)
current_camera_index = 0  # 默认摄像头索引
cap = None  # 视频捕捉对象
video_thread = None  # 视频流线程

# 初始化 MediaPipe 的 Pose 模块
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils

def findAngle(x1, y1, x2, y2):
    """计算两点之间的角度，用于姿势判断"""
    theta = math.acos((y2 - y1) * (-y1) / (math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2) * y1))
    degree = int(180 / math.pi) * theta
    return degree

def get_available_cameras():
    index = 0
    arr = []
    while True:
        try:
            cap = cv2.VideoCapture(index)
            if not cap.read()[0]:
                break
            arr.append(index)
            cap.release()
        except Exception as e:
            print(f"Error accessing camera {index}: {e}")
        index += 1
    print("Available cameras:", arr)
    return arr

@app.route('/cameras', methods=['GET'])
def list_cameras():
    cameras = get_available_cameras()
    return jsonify(cameras)

@app.route('/select_camera', methods=['POST'])
def select_camera():
    global current_camera_index, cap, video_thread

    # 关闭当前摄像头
    if cap is not None:
        cap.release()

    # 获取新的摄像头索引
    current_camera_index = request.json.get("index", 0)

    # 启动视频流处理线程
    if video_thread is not None and video_thread.is_alive():
        video_thread.join()
    
    video_thread = threading.Thread(target=generate_video_feed)
    video_thread.start()
    print(f"Using camera {current_camera_index}, thread started: {video_thread.is_alive()}")

    return jsonify({"status": "success", "camera_index": current_camera_index})

def generate_video_feed():
    global current_camera_index, cap
    cap = cv2.VideoCapture(current_camera_index)
    print(f"Using camera {current_camera_index}")
    print(f"Camera opened: {cap.isOpened()}")
    

    # 初始化 MediaPipe Pose
    with mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5) as pose:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            # 转换颜色格式：OpenCV 使用 BGR，MediaPipe 使用 RGB
            image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            # 处理图像
            results = pose.process(image)

            # 将图像颜色转换回 BGR 以便显示
            image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

            # 姿态检测
            if results.pose_landmarks:
                mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)

                # 获取关键点
                landmarks = results.pose_landmarks.landmark
                h, w, _ = frame.shape

                # 歪头监控
                left_ear_x = int(landmarks[mp_pose.PoseLandmark.LEFT_EAR].x * w)    # 左耳（7点）x 坐标         
                left_ear_y = int(landmarks[mp_pose.PoseLandmark.LEFT_EAR].y * h)    # 左耳（7点）y 坐标
                right_ear_x = int(landmarks[mp_pose.PoseLandmark.RIGHT_EAR].x * w)  # 右耳（8点）x 坐标
                right_ear_y = int(landmarks[mp_pose.PoseLandmark.RIGHT_EAR].y * h)  # 右耳（8点）y 坐标

                # 低头监控
                left_mouth_x = int(landmarks[mp_pose.PoseLandmark.MOUTH_LEFT].x * w)    # 左嘴角（9点）x 坐标
                left_mouth_y = int(landmarks[mp_pose.PoseLandmark.MOUTH_LEFT].y * h)    # 左嘴角（9点）y 坐标
                left_shoulder_x = int(landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].x * w)    # 左肩膀（11点）x 坐标
                left_shoulder_y = int(landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y * h)    # 左肩膀（11点）y 坐标

                # 侧脸监控
                left_eye_inner_x = int(landmarks[mp_pose.PoseLandmark.LEFT_EYE_INNER].x * w)    # 左眼内（1点）x 坐标
                left_eye_inner_y = int(landmarks[mp_pose.PoseLandmark.LEFT_EYE_INNER].y * h)    # 左眼内（1点）y 坐标
                right_eye_inner_x = int(landmarks[mp_pose.PoseLandmark.RIGHT_EYE_INNER].x * w)  # 右眼内（4点）x 坐标
                right_eye_inner_y = int(landmarks[mp_pose.PoseLandmark.RIGHT_EYE_INNER].y * h)  # 右眼内（4点）y 坐标

                # 高低肩监控
                right_shoulder_x = int(landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].x * w)  # 右肩膀（12点）x 坐标
                right_shoulder_y = int(landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].y * h)  # 右肩膀（12点）y 坐标

                # 撑桌监控
                right_mouth_x = int(landmarks[mp_pose.PoseLandmark.MOUTH_RIGHT].x * w)  # 左嘴角（10点）x 坐标
                right_mouth_y = int(landmarks[mp_pose.PoseLandmark.MOUTH_RIGHT].y * h)  # 左嘴角（10点）y 坐标

                # 仰头监控
                nose_x = int(landmarks[mp_pose.PoseLandmark.NOSE].x * w)    # 鼻子（0点）x 坐标
                nose_y = int(landmarks[mp_pose.PoseLandmark.NOSE].y * h)    # 鼻子（0点）y 坐标

                # 趴桌监控
                left_shoulder_x_norm = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].x  # 左肩膀（11点）x 坐标-归一化
                left_shoulder_y_norm = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y  # 左肩膀（11点）y 坐标-归一化
                right_shoulder_x_norm = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].x  # 右肩膀（12点）x 坐标-归一化
                right_shoulder_y_norm = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].y  # 右肩膀（12点）y 坐标-归一化

                results_detect = all_detection(nose_x, nose_y,
                  left_eye_inner_x, left_eye_inner_y,
                  right_eye_inner_x, right_eye_inner_y,
                  left_ear_x, left_ear_y,
                  right_ear_x, right_ear_y,
                  left_mouth_x, left_mouth_y,
                  right_mouth_x, right_mouth_y,
                  left_shoulder_x, left_shoulder_y,
                  right_shoulder_x, right_shoulder_y,
                  left_shoulder_x_norm, left_shoulder_y_norm,
                  right_shoulder_x_norm, right_shoulder_y_norm)


                # # 获取左嘴角(9)和左肩膀(11)的坐标
                # left_mouth_x = int(landmarks[mp_pose.PoseLandmark.MOUTH_LEFT].x * w)
                # left_mouth_y = int(landmarks[mp_pose.PoseLandmark.MOUTH_LEFT].y * h)
                # left_shoulder_x = int(landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].x * w)
                # left_shoulder_y = int(landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y * h)

                # # 计算夹角来判断是否低头
                # ditou_inclination = findAngle(left_mouth_x, left_mouth_y, left_shoulder_x, left_shoulder_y)
                
                # # 判断是否低头
                # if ditou_inclination < 115:
                #     head_position = '低头'
                # else:
                #     head_position = '正常'

                # 将姿势信息添加到图像上
                cv2.putText(image, results_detect, (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

            # 将图像编码为 JPEG 格式
            _, jpeg = cv2.imencode('.jpg', image)
            frame = jpeg.tobytes()

            # 返回帧
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

    cap.release()

@app.route('/video_feed')
def video_feed():
    return Response(generate_video_feed(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
