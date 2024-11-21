import cv2
from flask import Flask, jsonify, request, Response
import mediapipe as mp
from flask_cors import CORS
import threading
import math
from detect.utils import all_detection
from flasgger import Swagger  # Import flasgger
import time

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


def find_angle(x1, y1, x2, y2):
    """Calculate the angle between two points."""
    theta = math.acos((y2 - y1) * (-y1) / (math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2) * y1))
    return int(180 / math.pi) * theta

def get_available_cameras():
    """Detect and list available camera indices."""
    available_cams = []
    index = 0
    while True:
        try:
            cap = cv2.VideoCapture(index)
            if not cap.read()[0]:  # Check if the camera is available
                break
            available_cams.append(index)
            cap.release()
        except Exception as e:
            print(f"Error accessing camera {index}: {e}")
        index += 1
    return available_cams

@app.route('/cameras', methods=['GET'])
def list_cameras():
    """
    Get list of available cameras.
    ---
    responses:
      200:
        description: List of available camera indices.
        examples:
          application/json: [0, 1, 2]
    """
    return jsonify(get_available_cameras())

@app.route('/select_camera', methods=['POST'])
def select_camera():
    """
    Select the camera to stream video.
    ---
    parameters:
      - name: index
        in: body
        type: integer
        required: true
        description: Index of the camera to select.
    responses:
      200:
        description: Status of camera selection.
        examples:
          application/json: {"status": "success", "camera_index": 1}
    """
    global current_camera_index, cap, video_thread

    # Stop and release the current camera
    if cap:
        cap.release()

    # Set new camera index
    current_camera_index = request.json.get("index", 0)

    # Stop any existing video stream thread
    if video_thread and video_thread.is_alive():
        video_thread.join()

    # Start new thread for video stream
    video_thread = threading.Thread(target=generate_video_feed)
    video_thread.start()

    return jsonify({"status": "success", "camera_index": current_camera_index})

def generate_video_feed():
    """Stream video feed from the selected camera."""
    global cap, posture_start_time, current_posture
    cap = cv2.VideoCapture(current_camera_index)
    if not cap.isOpened():
        print("Failed to open camera.")
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
                            posture_times[current_posture] = 0
                        posture_times[current_posture] += elapsed_time
                    current_posture = posture
                    posture_start_time = time.time()
                else:
                    if posture_start_time and time.time() - posture_start_time > 1:
                        posture_times[current_posture] = time.time() - posture_start_time

                # Draw border around the frame based on posture
                if posture == "normal":
                    border_color = (0, 255, 0)  # Green border for correct posture
                else:
                    border_color = (0, 0, 255)  # Red border for incorrect posture

                # Draw a border around the frame
                thickness = 10
                cv2.rectangle(image, (0, 0), (w, h), border_color, thickness)

                cv2.putText(image, posture, (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

            # Draw eye landmarks if face mesh is available
            if results_face.multi_face_landmarks:
                for face_landmarks in results_face.multi_face_landmarks:
                    # Draw the landmarks of the eyes
                    left_eye = face_landmarks.landmark[33]  # Left eye center
                    right_eye = face_landmarks.landmark[133]  # Right eye center
                    left_eye_coords = (int(left_eye.x * w), int(left_eye.y * h))
                    right_eye_coords = (int(right_eye.x * w), int(right_eye.y * h))

                    # Draw circles around the eyes
                    cv2.circle(image, left_eye_coords, 5, (255, 0, 0), -1)  # Blue dot for left eye
                    cv2.circle(image, right_eye_coords, 5, (0, 0, 255), -1)  # Red dot for right eye

            # Encode the frame as JPEG
            _, jpeg = cv2.imencode('.jpg', image)
            frame = jpeg.tobytes()

            # Return the frame as a stream
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

    cap.release()

def detect_posture(landmarks, width, height):
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
    # Posture check (e.g., head tilt or slouching)
    return results_detect

@app.route('/video_feed')
def video_feed():
    """
    Stream video feed from the selected camera.
    ---
    responses:
      200:
        description: Stream video frames in JPEG format.
        content:
          multipart/x-mixed-replace:
            schema:
              type: string
              format: byte
    """
    return Response(generate_video_feed(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/posture_times', methods=['GET'])
def get_posture_times():
    """
    Get the time spent in each posture.
    ---
    responses:
      200:
        description: Time spent in each posture.
        examples:
          application/json: {"normal": 45, "left tilt": 30, "right tilt": 20}
    """
    return jsonify(posture_times)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
