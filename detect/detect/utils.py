import math as m


# 度量函数
# 计算两点之间的夹角。函数接收两个点 (x1, y1) 和 (x2, y2)，计算这两点形成的直线与水平线之间的角度（单位为度）。返回值为角度值。
def findAngle(x1, y1, x2, y2):
    theta = m.acos((y2 - y1) * (-y1) / (m.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2) * y1))
    degree = int(180/m.pi)*theta
    return degree

"""
歪头监控：计算 左耳（7点）和 右耳（8点）的夹角
低头监控：计算 左嘴角（9点）和 左肩膀（11点）的夹角
侧脸监控：计算 右眼内（4点）和 左耳（7点）的距离，计算 左眼内（1点）和 右耳（8点）的距离
高低肩监控：计算 左肩膀（11点）和 右肩膀（12点）的夹角            *****有的人左肩和右肩一个高一个低*****
撑桌监控：如果 左嘴角（9点）或者 右嘴角（10点）的 y 坐标 大于 左肩膀（11点）或 右肩膀（12点）的 y 坐标，视为撑桌
仰头监控：计算 鼻子（0点）和 左耳（7点）的夹角
趴桌监控：如果 左肩膀（11点）和 右肩膀（12点）的 归一化y坐标 之和大于0.75，判定为趴桌
"""
def all_detection(nose_x, nose_y,                               # 鼻子（0点）的 x 坐标 和 y 坐标
                  left_eye_inner_x, left_eye_inner_y,           # 左眼内（1点）的 x 坐标 和 y 坐标
                  right_eye_inner_x, right_eye_inner_y,         # 右眼内（4点）的 x 坐标 和 y 坐标
                  left_ear_x, left_ear_y,                       # 左耳（7点）的 x 坐标 和 y 坐标
                  right_ear_x, right_ear_y,                     # 右耳（8点）的 x 坐标 和 y 坐标
                  left_mouth_x, left_mouth_y,                   # 左嘴角（9点）的 x 坐标 和 y 坐标
                  right_mouth_x, right_mouth_y,                 # 右嘴角（10点）的 x 坐标 和 y 坐标
                  left_shoulder_x, left_shoulder_y,             # 左肩膀（11点）的 x 坐标 和 y 坐标
                  right_shoulder_x, right_shoulder_y,           # 右肩膀（12点）的 x 坐标 和 y 坐标
                  left_shoulder_x_norm, left_shoulder_y_norm,   # 归一化后的左肩膀（11点）的 x 坐标 和 y 坐标
                  right_shoulder_x_norm, right_shoulder_y_norm  # 归一化后的右肩膀（12点）的 x 坐标 和 y 坐标
                  ):
    waitou_inclination = findAngle(left_ear_x, left_ear_y, right_ear_x, right_ear_y) 
    ditou_inclination = findAngle(left_mouth_x, left_mouth_y, left_shoulder_x, left_shoulder_y)
    gaodijian_inclination = findAngle(left_shoulder_x, left_shoulder_y, right_shoulder_x, right_shoulder_y)
    yangtou_inclination = findAngle(nose_x, nose_y, left_ear_x, left_ear_y)
    if waitou_inclination < 80:
        tmp = 'left tilt'
    elif waitou_inclination > 100:
        tmp = 'right tilt'
    elif (left_shoulder_y_norm + right_shoulder_y_norm) > 1.6:
        tmp = 'lying down in the chair'
    elif ditou_inclination < 115:
        tmp = 'bow'
    elif left_ear_x < right_eye_inner_x:
        tmp = 'left face'
    elif right_ear_x > left_eye_inner_x:
        tmp = 'right face'
    elif gaodijian_inclination > 100:
        tmp = 'high shoulder'
    elif gaodijian_inclination < 80:
        tmp = 'low shoulder'
    elif (left_mouth_y or right_mouth_y) > (left_shoulder_y or right_shoulder_y):
        tmp = 'supporting the table'
    elif yangtou_inclination > 90:
        tmp = 'looking up'
    else:
        tmp = 'normal'
    return tmp


def all_detection_new(landmarks, width, height):
    """Analyze pose landmarks and determine posture conditions."""
    # Extract key points
    left_ear = landmarks[mp_pose.PoseLandmark.LEFT_EAR]
    right_ear = landmarks[mp_pose.PoseLandmark.RIGHT_EAR]
    left_eye_inner = landmarks[mp_pose.PoseLandmark.LEFT_EYE_INNER]
    left_eye_outer = landmarks[mp_pose.PoseLandmark.LEFT_EYE_OUTER]
    right_eye_inner = landmarks[mp_pose.PoseLandmark.RIGHT_EYE_INNER]
    right_eye_outer = landmarks[mp_pose.PoseLandmark.RIGHT_EYE_OUTER]
    nose = landmarks[mp_pose.PoseLandmark.NOSE]
    left_eye = landmarks[mp_pose.PoseLandmark.LEFT_EYE]
    right_eye = landmarks[mp_pose.PoseLandmark.RIGHT_EYE]
    left_shoulder = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER]
    right_shoulder = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER]
    left_mouth = landmarks[mp_pose.PoseLandmark.MOUTH_LEFT]
    right_mouth = landmarks[mp_pose.PoseLandmark.MOUTH_RIGHT]

    # Compute relevant distances and angles for posture analysis
    left_ear_x, left_ear_y = int(left_ear.x * width), int(left_ear.y * height)
    right_ear_x, right_ear_y = int(right_ear.x * width), int(right_ear.y * height)
    nose_x, nose_y = int(nose.x * width), int(nose.y * height)
    left_eye_x, left_eye_y = int(left_eye.x * width), int(left_eye.y * height)
    right_eye_x, right_eye_y = int(right_eye.x * width), int(right_eye.y * height)
    left_eye_inner_x, left_eye_inner_y = int(left_eye_inner.x * width), int(left_eye_inner.y * height)
    right_eye_inner_x, right_eye_inner_y = int(right_eye_inner.x * width), int(right_eye_inner.y * height)
    left_eye_outer_x, left_eye_outer_y = int(left_eye_outer.x * width), int(left_eye_outer.y * height)
    right_eye_outer_x, right_eye_outer_y = int(right_eye_outer.x * width), int(right_eye_outer.y * height)
    left_shoulder_x, left_shoulder_y = int(left_shoulder.x * width), int(left_shoulder.y * height)
    right_shoulder_x, right_shoulder_y = int(right_shoulder.x * width), int(right_shoulder.y * height)
    left_mouth_x, left_mouth_y = int(left_mouth.x * width), int(left_mouth.y * height)
    right_mouth_x, right_mouth_y = int(right_mouth.x * width), int(right_mouth.y * height)

    left_shoulder_x_norm, left_shoulder_y_norm = left_shoulder.x, left_shoulder.y
    right_shoulder_x_norm, right_shoulder_y_norm = right_shoulder.x, right_shoulder.y

    waitou_inclination = findAngle(left_ear_x, left_ear_y, right_ear_x, right_ear_y) 
    ditou_inclination = findAngle(left_mouth_x, left_mouth_y, left_shoulder_x, left_shoulder_y)
    gaodijian_inclination = findAngle(left_shoulder_x, left_shoulder_y, right_shoulder_x, right_shoulder_y)
    yangtou_inclination = findAngle(nose_x, nose_y, left_ear_x, left_ear_y)
    if waitou_inclination < 80:
        tmp = 'left tilt'
    elif waitou_inclination > 100:
        tmp = 'right tilt'
    elif (left_shoulder_y_norm + right_shoulder_y_norm) > 1.5:
        tmp = 'lying on the table'
    elif ditou_inclination < 115:
        tmp = 'bow'
    elif left_ear_x < right_eye_inner_x:
        tmp = 'left face'
    elif right_ear_x > left_eye_inner_x:
        tmp = 'right face'
    elif gaodijian_inclination > 100:
        tmp = 'high shoulder'
    elif gaodijian_inclination < 80:
        tmp = 'low shoulder'
    elif (left_mouth_y or right_mouth_y) > (left_shoulder_y or right_shoulder_y):
        tmp = 'supporting the table'
    elif yangtou_inclination > 90:
        tmp = 'looking up'
    else:
        tmp = 'normal'
    return tmp


