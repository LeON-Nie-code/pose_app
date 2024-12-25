import os
import random
import cv2
from flask import Flask, jsonify, request, Response
import mediapipe as mp
from flask_cors import CORS
import threading
import math
from detect.utils import all_detection
from flasgger import Swagger  # Import flasgger
import time
import logging

import psutil

def log_service_performance():
    """Log performance metrics using psutil."""
    process = psutil.Process()  # Current process
    while True:
        try:
            cpu_usage = process.cpu_percent(interval=1)
            memory_info = process.memory_info()
            net_io = psutil.net_io_counters()
            disk_io = psutil.disk_io_counters()

            logging.info(f"CPU Usage: {cpu_usage}%")
            logging.info(f"Memory Usage: {memory_info.rss / 1024 / 1024:.2f} MB")
            logging.info(f"Network - Sent: {net_io.bytes_sent / 1024 / 1024:.2f} MB, "
                         f"Received: {net_io.bytes_recv / 1024 / 1024:.2f} MB")
            logging.info(f"Disk - Read: {disk_io.read_bytes / 1024 / 1024:.2f} MB, "
                         f"Write: {disk_io.write_bytes / 1024 / 1024:.2f} MB")

            # Sleep for a short period before logging the next set of metrics
            time.sleep(5)
        except Exception as e:
            logging.error(f"Error logging performance metrics: {e}")
            break

# 获取当前文件的目录
current_dir = os.path.dirname(os.path.abspath(__file__))
print(current_dir)

# 设置日志文件的路径
log_dir = os.path.join(current_dir, 'logs')
log_file_path = os.path.join(log_dir, 'app.log')

# 检查并创建日志目录
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename=log_file_path,  # 使用相对路径
    filemode='a'
)

app = Flask(__name__)
CORS(app)
swagger = Swagger(app)  # Initialize Swagger

current_camera_index = 0  # Default camera index
cap = None  # Video capture object
video_thread = None  # Video stream thread

# Initialize MediaPipe Pose module
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
mp_face_mesh = mp.solutions.face_mesh

# Store the posture durations
posture_times = {}  # Key: posture name, Value: duration in seconds
current_posture = None  # Current posture being tracked
posture_start_time = None  # Start time of the current posture

current_eye_status = None  # Current eye status being tracked
eye_start_time = None  # Start time of the current eye status
eye_times = {}  # Key: eye status name, Value: duration in seconds


# Session start and end times
session_start_time = None
session_end_time = None


def find_angle(x1, y1, x2, y2):
    """Calculate the angle between two points."""
    theta = math.acos((y2 - y1) * (-y1) / (math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2) * y1))
    return int(180 / math.pi) * theta





def generate_video_feed(draw_dots=True):
    """Stream video feed from the selected camera."""
    global cap, posture_start_time, current_posture,session_end_time, session_start_time, posture_times, current_eye_status, eye_start_time, eye_times
    try:

        cap = cv2.VideoCapture(current_camera_index)
        if not cap.isOpened():
            print("Failed to open camera.")
            logging.error("Failed to open camera.")
            return

        # Initialize MediaPipe Pose and Face Mesh
        with mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5) as pose, \
            mp_face_mesh.FaceMesh(min_detection_confidence=0.5, min_tracking_confidence=0.5) as face_mesh:
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break

                # Convert color format: OpenCV uses BGR, MediaPipe uses RGB
                image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                results_pose = pose.process(image)
                results_face = face_mesh.process(image)

                # Convert back to BGR for display
                image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

                if results_pose.pose_landmarks:
                    if draw_dots:
                        mp_drawing.draw_landmarks(image, results_pose.pose_landmarks, mp_pose.POSE_CONNECTIONS)
                    landmarks = results_pose.pose_landmarks.landmark
                    h, w, _ = frame.shape
                    
                    # Detect posture by analyzing key points
                    posture = detect_posture(landmarks, w, h)

                    # Update posture time if posture changes
                    if posture != current_posture:
                        if current_posture and posture_start_time:
                            elapsed_time = time.time() - posture_start_time
                            if current_posture not in posture_times:
                                print(f"New posture detected: {current_posture}")
                                logging.info(f"New posture detected: {current_posture}")
                                posture_times[current_posture] = 0
                            if elapsed_time > 1:
                                # print(f"Adding {elapsed_time} seconds to {current_posture}")
                                posture_times[current_posture] += elapsed_time
                        current_posture = posture
                        if current_posture not in posture_times:
                            posture_times[current_posture] = 0
                        posture_start_time = time.time()
                    else:
                        if posture_start_time and time.time() - posture_start_time > 1:
                            # print(f"Adding 1 second to {current_posture}")
                            posture_times[current_posture] += time.time() - posture_start_time
                            posture_start_time = time.time()
    
                            
                    
                    # print(posture_times)

                    # Draw border around the frame based on posture
                    if posture == "normal":
                        border_color = (0, 255, 0)  # Green border for correct posture
                    else:
                        border_color = (0, 0, 255)  # Red border for incorrect posture

                    # Draw a border around the frame
                    thickness = 10
                    cv2.rectangle(image, (0, 0), (w, h), border_color, thickness)

                    if draw_dots:
                        cv2.putText(image, posture, (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

                eye_status = "Looking at screen"

                # Draw eye landmarks if face mesh is available
                if results_face.multi_face_landmarks:
                    h, w, _ = frame.shape
                    for face_landmarks in results_face.multi_face_landmarks:
                        # Draw the landmarks of the eyes
                        left_eye = face_landmarks.landmark[33]  # Left eye center
                        right_eye = face_landmarks.landmark[133]  # Right eye center
                        left_eye_coords = (int(left_eye.x * w), int(left_eye.y * h))
                        right_eye_coords = (int(right_eye.x * w), int(right_eye.y * h))
                        
                        

                        if draw_dots:
                            # Draw circles around the eyes
                            cv2.circle(image, left_eye_coords, 5, (255, 0, 0), -1)  # Blue dot for left eye
                            cv2.circle(image, right_eye_coords, 5, (255, 0, 0), -1)  # Red dot for right eye

                        # Eye gaze detection (checking if eyes are in the center of the screen)
                        eye_status = check_eye_position(left_eye_coords, right_eye_coords, w, h)

                        looking_at_screen = detect_eye_test(landmarks, w, h)
                        if not looking_at_screen:
                            eye_status = 'Not looking at screen'

                        if posture == "bow" or posture == "looking up":
                            eye_status = "Not looking at screen"

                        # if posture == "normal" and eye_status == "Looking at screen":
                        #     cv2.putText(image, "Good posture and eye gaze", (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)


                        if draw_dots:
                            cv2.putText(image, eye_status, (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
                
                # Update eye status time if eye status changes
                if eye_status != current_eye_status:
                    if current_eye_status and eye_start_time:
                        elapsed_time = time.time() - eye_start_time
                        if current_eye_status not in eye_times:
                            print(f"New eye status detected: {current_eye_status}")
                            logging.info(f"New eye status detected: {current_eye_status}")
                            eye_times[current_eye_status] = 0
                        if elapsed_time > 1:
                            # print(f"Adding {elapsed_time} seconds to {current_eye_status}")
                            eye_times[current_eye_status] += elapsed_time
                    current_eye_status = eye_status
                    if current_eye_status not in eye_times:
                        eye_times[current_eye_status] = 0
                    eye_start_time = time.time()
                else:
                    if eye_start_time and time.time() - eye_start_time > 1:
                        # print(f"Adding 1 second to {current_eye_status}")
                        eye_times[current_eye_status] += time.time() - eye_start_time
                        eye_start_time = time.time()

                # Encode the frame as JPEG
                _, jpeg = cv2.imencode('.jpg', image)
                frame = jpeg.tobytes()

                # Return the frame as a stream
                yield (b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
    finally:
        # Record the end time of the session
        end_time = time.time()
        # Release the camera
        if cap:
            cap.release()
        # Log the end of the video feed
        logging.info("Video feed has ended at %s", time.ctime(end_time))
            
    cap.release()

def check_eye_position(left_eye_coords, right_eye_coords, frame_width, frame_height):
    """Check if the eyes are within the center of the screen."""
    # Determine the screen center
    screen_center_x, screen_center_y = frame_width // 2, frame_height // 2

    # Check if both eyes are near the screen center (a simple heuristic)
    eye_distance = math.sqrt((left_eye_coords[0] - right_eye_coords[0]) ** 2 +
                             (left_eye_coords[1] - right_eye_coords[1]) ** 2)
    
    # Define a threshold for how far the eyes can be from the center to be considered "looking at the screen"
    max_eye_offset = frame_width * 0.3  # 30% of screen width

    # Check if the distance from the center is within the allowed offset
    if abs(left_eye_coords[0] - screen_center_x) < max_eye_offset and abs(right_eye_coords[0] - screen_center_x) < max_eye_offset:
        eye_status = "Looking at screen"
        eye_color = (0, 255, 0)  # Green for looking at screen
    else:
        eye_status = "Not looking at screen"
        eye_color = (0, 0, 255)  # Red for not looking at screen

    logging.debug(f"Eye status: {eye_status}")
    return eye_status

    # Display the eye status on the frame
    # cv2.putText(frame, eye_status, (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, eye_color, 2)


def detect_posture(landmarks, width, height):
    """Analyze pose landmarks and determine posture conditions."""
    # Extract key points
    left_ear = landmarks[mp_pose.PoseLandmark.LEFT_EAR]
    ...  # Add more landmarks as needed

    # Compute relevant distances and angles for posture analysis
    left_ear_x, left_ear_y = int(left_ear.x * width), int(left_ear.y * height)
    right_ear_x, right_ear_y = int(right_ear.x * width), int(right_ear.y * height)
    ...  # Add more landmarks as needed

    

    results_detect = all_detection(nose_x,...)
    # Posture check (e.g., head tilt or slouching)

    # Posture check (e.g., head tilt or slouching)
    logging.debug(f"Detected posture: {results_detect}")
    return results_detect


def detect_eye_test(landmarks, width, height):
    """Analyze pose landmarks and determine posture conditions."""
    # Extract key points
    left_ear = landmarks[mp_pose.PoseLandmark.LEFT_EAR]
    right_ear = landmarks[mp_pose.PoseLandmark.RIGHT_EAR]
    ...  # Add more landmarks as needed

    eye_status = 'Looking at screen'
    
    if left_ear_x < right_eye_inner_x:
        eye_status = 'left face'
    elif right_ear_x > left_eye_inner_x:
        eye_status = 'right face'
    

    if eye_status != 'Looking at screen':
        logging.debug(f"Eye test failed: {eye_status}")
        return False
    else:
        logging.debug("Eye test passed")
        return True
        

@app.route('/video_feed')
def video_feed():


    global session_start_time, session_end_time

    # Record the start time of the session
    session_start_time = time.time()

    # Log the start of the video feed
    logging.info("Video feed started at %s", time.ctime(session_start_time))

    # Get the camera index from the query parameters, default to 0
    camera_index = request.args.get('index', default=0, type=int)

    # Stop and release the current camera
    global cap
    if cap:
        cap.release()

    # Set the new camera index
    global current_camera_index
    current_camera_index = camera_index

    # Start streaming video from the selected camera
    logging.info(f"Streaming video from camera index {camera_index}")
    return Response(generate_video_feed(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/video_feed_without_dots')
def video_feed_without_dots():
    

    global session_start_time, session_end_time

    # Record the start time of the session
    session_start_time = time.time()

    # Log the start of the video feed
    logging.info("Video feed started at %s", time.ctime(session_start_time))

    # Get the camera index from the query parameters, default to 0
    camera_index = request.args.get('index', default=0, type=int)

    # Stop and release the current camera
    global cap
    if cap:
        cap.release()

    # Set the new camera index
    global current_camera_index
    current_camera_index = camera_index

    # Start streaming video from the selected camera
    logging.info(f"Streaming video from camera index {camera_index}")
    return Response(generate_video_feed(draw_dots=False), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/posture_times', methods=['GET'])
def get_posture_times():

    totle_time = 0
    for key in posture_times:
        totle_time += posture_times[key]
    posture_times_with_total = posture_times.copy()
    posture_times_with_total["total"] = totle_time
    logging.info(f"Posture times: {posture_times_with_total}")
    return jsonify(posture_times_with_total)


@app.route('/session_record', methods=['GET'])
def session_record():

    global session_start_time, session_end_time, posture_times
    session_end_time = time.time()
    print (session_start_time, session_end_time)
    if session_start_time is None or session_end_time is None:
        return jsonify({"error": "No session has been started or ended yet"}), 400

    session_duration = session_end_time - session_start_time
    posture_times_with_total = posture_times.copy()
    posture_times_with_total["total"] = sum(posture_times_with_total.values())
    posture_times_with_total["session_duration"] = session_duration

    eye_times_with_total = eye_times.copy()
    eye_times_with_total["total"] = sum(eye_times_with_total.values())
    eye_times_with_total["session_duration"] = session_duration

    logging.info(f"Session record: {posture_times_with_total}")

    result = {
        "start_time": session_start_time,
        "duration": session_duration,
        "end_time": session_end_time,
        "posture_times": posture_times_with_total,
        "eye_times": eye_times_with_total
    }

    return jsonify(result)

@app.route("/")
def home():
    return "Welcome to Pose App!"

if __name__ == "__main__":
    # performance_thread = threading.Thread(target=log_service_performance, daemon=True)
    # performance_thread.start()
    app.run(host='0.0.0.0', port=5000, debug=True)
