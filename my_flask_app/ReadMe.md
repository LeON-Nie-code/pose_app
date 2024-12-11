## Command

python3 -m venv 
source venv/bin/activate
pip install -r requirements.txt



gunicorn -w 4 -b 0.0.0.0:8889 app:app

sudo tail -f /var/log/nginx/error.log

flask db migrate -m "Add eye_time to user_detection_records."


flask db upgrade


{
  "duration": 29,
  "end_time": 1733925614,
  "eye_times": {
    "Looking at screen": 52.72097086906433,
    "Not looking at screen": 22.45505428314209,
    "session_duration": 29.500812292099,
    "total": 75.17602515220642
  },
  "posture_times": {
    "bow": 1.0090792179107666,
    "left face": 0,
    "left tilt": 4.075720548629761,
    "lying down in the chair": 20.344781637191772,
    "normal": 46.01675343513489,
    "right face": 1.0387811660766602,
    "right tilt": 3.0779740810394287,
    "session_duration": 29.500812292099,
    "total": 75.56309008598328
  },
  "start_time": 1733925584
}
