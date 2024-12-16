## Command

python3 -m venv 
source venv/bin/activate
pip install -r requirements.txt

python3 app.py



gunicorn -w 4 -b 0.0.0.0:8889 app:app

sudo tail -f /var/log/nginx/error.log

flask db migrate -m "Add eye_time to user_detection_records."

 
flask db upgrade


nohup python3 app.py &

netstat -tulnp | grep 8889



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


curl -X POST http://8.217.68.60/post \
     -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTczNDMzNzk0NCwianRpIjoiOGE4M2Y0NjYtOGM2Zi00OWRkLWI4NmEtMTA0ODc0MWMxYjQ5IiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjIiLCJuYmYiOjE3MzQzMzc5NDQsImNzcmYiOiI4ZDVlZGI0Yy01ZWJjLTQwZjktYTkxMS1kMDI3ZDA5MTc3YWYiLCJleHAiOjE3MzQzNDE1NDR9.bTH_wwBnDYR3swvgGofwDdrX-nTmgEa3U19_0n4RoOM" \
     -F "title=My New Post" \
     -F "content=This is the content of my new post." \
     -F "photo1=@1.jpg"