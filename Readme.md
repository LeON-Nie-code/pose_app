# pose_app

这是一项使用media_pipe对坐姿进行检测的Windows桌面APP

## 安装
1. 使用源码构建，使用方法见下文
2. 在官网 http://poseapp.top/ 来下载安装程序，执行即可自动安装
3. 在https://cloud.tsinghua.edu.cn/f/8a321560f4384b19ae45/?dl=1获取安装程序

## 文件结构

```
.
├── Readme.md
├── detect
│   ├── ReadMe.md
│   ├── __init__.py
│   ├── app.py
│   ├── app.spec
│   ├── app_backup.txt
│   ├── build
│   │   └── app
│   ├── dataAnalyze.py
│   ├── detect
│   │   ├── __init__.py
│   │   ├── __pycache__
│   │   ├── hand.py
│   │   ├── main.py
│   │   └── utils.py
│   ├── dist
│   │   └── app
│   ├── logs
│   │   └── app.log
│   ├── requirements.txt
│   ├── test
│   │   ├── performance_test.py
│   │   ├── videoTest.py
│   │   └── videotest.txt
│   └── venv
│       ├── Include
│       ├── Lib
│       ├── Scripts
│       ├── pyvenv.cfg
│       └── share
├── flutter
│   ├── README.md
│   ├── analysis_options.yaml
│   ├── android
│   │   ├── app
│   │   ├── build.gradle
│   │   ├── gradle
│   │   ├── gradle.properties
│   │   ├── local.properties
│   │   └── settings.gradle
│   ├── assets
│   │   ├── fonts
│   │   ├── icons
│   │   └── sounds
│   ├── build
│   │   ├── 717511621608fe9d75a335a408fd62bb
│   │   ├── cache.dill.track.dill
│   │   ├── flutter_assets
│   │   ├── native_assets
│   │   └── windows
│   ├── error_log.html
│   ├── flutter_01.png
│   ├── fonts
│   │   ├── Poppins-Bold.ttf
│   │   ├── Poppins-Medium.ttf
│   │   ├── Poppins-Regular.ttf
│   │   └── Poppins-SemiBold.ttf
│   ├── ios
│   │   ├── Flutter
│   │   ├── Runner
│   │   ├── Runner.xcodeproj
│   │   ├── Runner.xcworkspace
│   │   └── RunnerTests
│   ├── lib
│   │   ├── Calendar
│   │   ├── Community
│   │   ├── Setting
│   │   ├── SignOut
│   │   ├── StatisticsPage
│   │   ├── config
│   │   ├── data.dart
│   │   ├── homepage
│   │   ├── main.dart
│   │   ├── rankingData.dart
│   │   ├── statistic_data.dart
│   │   ├── style
│   │   ├── userAccount
│   │   └── utils
│   ├── linux
│   │   ├── CMakeLists.txt
│   │   ├── flutter
│   │   ├── main.cc
│   │   ├── my_application.cc
│   │   └── my_application.h
│   ├── macos
│   │   ├── Flutter
│   │   ├── Runner
│   │   ├── Runner.xcodeproj
│   │   ├── Runner.xcworkspace
│   │   └── RunnerTests
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   ├── test
│   │   └── widget_test.dart
│   ├── web
│   │   ├── favicon.png
│   │   ├── icons
│   │   ├── index.html
│   │   └── manifest.json
│   └── windows
│       ├── CMakeLists.txt
│       ├── flutter
│       └── runner
├── meetings.md
├── my_flask_app
│   ├── ReadMe.md
│   ├── SendCode
│   │   ├── ReadMe.md
│   │   ├── __init__.py
│   │   ├── __pycache__
│   │   └── send.py
│   ├── __pycache__
│   │   ├── app.cpython-310.pyc
│   │   ├── app.cpython-312.pyc
│   │   ├── config.cpython-310.pyc
│   │   ├── config.cpython-312.pyc
│   │   ├── models.cpython-310.pyc
│   │   ├── models.cpython-312.pyc
│   │   ├── routes.cpython-310.pyc
│   │   └── routes.cpython-312.pyc
│   ├── app.py
│   ├── config.py
│   ├── instance
│   │   └── site.db
│   ├── migrations
│   │   ├── README
│   │   ├── __pycache__
│   │   ├── alembic.ini
│   │   ├── env.py
│   │   ├── script.py.mako
│   │   └── versions
│   ├── models.py
│   ├── nohup.out
│   ├── requirements.txt
│   ├── routes.py
│   ├── temp.py
│   └── venv
│       ├── bin
│       ├── include
│       ├── lib
│       ├── lib64
│       └── pyvenv.cfg
├── output.md
├── specification.md
└── todo.md

```

## 前端

使用Flutter构建前端。

## 检测

通过在本机启动通过Flask代理的detect检测的后端服务，来调用摄像头，对获取到的画面使用media_pipe对人体结构进行分析。

## 服务器后端

在服务器端使用Flask代理服务，来完成用户数据的管理。

## 使用方法

在detect文件夹下执行
```bash
python -m venv venv 
venv\Scripts\activate
pip install -r requirements.txt
python app.py
```
即可在 http://127.0.0.1:5000 提供API服务

在flutter文件夹下执行
```bash
flutter run -d windows
```
即可运行flutter前端应用


在my_flask_app目录下执行
```bash
docker-compose build
docker-compose up
```

即可提供后端api服务




## 理论指导

使用电脑的坐姿 

1. https://www.uclahealth.org/safety/ergonomics/office-ergonomics/good-posture
2. https://ergonomictrends.com/proper-sitting-posture-computer-experts/
