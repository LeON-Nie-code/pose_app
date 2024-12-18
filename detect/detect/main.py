import cv2
import mediapipe as mp
from utils import *


mp_pose = mp.solutions.pose
pose = mp_pose.Pose(model_complexity=1, min_detection_confidence=0.5, min_tracking_confidence=0.5)
mp_drawing = mp.solutions.drawing_utils

cap = cv2.VideoCapture(0)

while True:
    # 读取每一帧图像。ret 表示是否成功读取，frame 是图像数据。
    ret, frame = cap.read()
    h, w = frame.shape[:2] # 获取图像的高和宽
    image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB) # 将 BGR 格式转换为 RGB 格式
    keypoints = pose.process(image) # 获取关键点信息到 keypoints 中

    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR) # 将 RGB 格式转换为 BGR 格式，方便 OpenCV 显示
    lm = keypoints.pose_landmarks # 得到一个包含人体关键点的对象。每个关键点的 x 和 y 坐标是归一化的，即值在 0 到 1 之间。
    lmPose = mp_pose.PoseLandmark # 供 MediaPipe 的标准关键点索引（如左耳、右耳、左眼等）。

    # 歪头监控
    left_ear_x = int(lm.landmark[lmPose.LEFT_EAR].x * w)    # 左耳（7点）x 坐标         
    left_ear_y = int(lm.landmark[lmPose.LEFT_EAR].y * h)    # 左耳（7点）y 坐标
    right_ear_x = int(lm.landmark[lmPose.RIGHT_EAR].x * w)  # 右耳（8点）x 坐标
    right_ear_y = int(lm.landmark[lmPose.RIGHT_EAR].y * h)  # 右耳（8点）y 坐标

    # 低头监控
    left_mouth_x = int(lm.landmark[lmPose.MOUTH_LEFT].x * w)    # 左嘴角（9点）x 坐标
    left_mouth_y = int(lm.landmark[lmPose.MOUTH_LEFT].y * h)    # 左嘴角（9点）y 坐标
    left_shoulder_x = int(lm.landmark[lmPose.LEFT_SHOULDER].x * w)    # 左肩膀（11点）x 坐标
    left_shoulder_y = int(lm.landmark[lmPose.LEFT_SHOULDER].y * h)    # 左肩膀（11点）y 坐标

    # 侧脸监控
    left_eye_inner_x = int(lm.landmark[lmPose.LEFT_EYE_INNER].x * w)    # 左眼内（1点）x 坐标
    left_eye_inner_y = int(lm.landmark[lmPose.LEFT_EYE_INNER].y * h)    # 左眼内（1点）y 坐标
    right_eye_inner_x = int(lm.landmark[lmPose.RIGHT_EYE_INNER].x * w)  # 右眼内（4点）x 坐标
    right_eye_inner_y = int(lm.landmark[lmPose.RIGHT_EYE_INNER].y * h)  # 右眼内（4点）y 坐标

    # 高低肩监控
    right_shoulder_x = int(lm.landmark[lmPose.RIGHT_SHOULDER].x * w)  # 右肩膀（12点）x 坐标
    right_shoulder_y = int(lm.landmark[lmPose.RIGHT_SHOULDER].y * h)  # 右肩膀（12点）y 坐标

    # 撑桌监控
    right_mouth_x = int(lm.landmark[lmPose.MOUTH_RIGHT].x * w)  # 左嘴角（10点）x 坐标
    right_mouth_y = int(lm.landmark[lmPose.MOUTH_RIGHT].y * h)  # 左嘴角（10点）y 坐标

    # 仰头监控
    nose_x = int(lm.landmark[lmPose.NOSE].x * w)    # 鼻子（0点）x 坐标
    nose_y = int(lm.landmark[lmPose.NOSE].y * h)    # 鼻子（0点）y 坐标

    # 趴桌监控
    left_shoulder_x_norm = lm.landmark[lmPose.LEFT_SHOULDER].x  # 左肩膀（11点）x 坐标-归一化
    left_shoulder_y_norm = lm.landmark[lmPose.LEFT_SHOULDER].y  # 左肩膀（11点）y 坐标-归一化
    right_shoulder_x_norm = lm.landmark[lmPose.RIGHT_SHOULDER].x  # 右肩膀（12点）x 坐标-归一化
    right_shoulder_y_norm = lm.landmark[lmPose.RIGHT_SHOULDER].y  # 右肩膀（12点）y 坐标-归一化

    results = all_detection(nose_x, nose_y,
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
    print(results)


    mp_drawing.draw_landmarks(image, keypoints.pose_landmarks, mp_pose.POSE_CONNECTIONS) # 将关键点连接起来
    cv2.imshow("Image", image) # 显示图像
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()

