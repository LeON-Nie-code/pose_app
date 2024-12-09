# pose_app

这是一项使用media_pipe对坐姿进行检测的Windows桌面APP

## 文件结构

```
.
├── Readme.md
├── backend
│   ├── db.sqlite3
│   ├── manage.py
│   ├── pose_remote
│   └── user
├── detect
│   ├── ReadMe.md
│   ├── __init__.py
│   ├── app.py
│   ├── detect
│   └── requirements.txt
├── flutter
│   ├── README.md
│   ├── analysis_options.yaml
│   ├── android
│   ├── assets
│   ├── build
│   ├── flutter_01.png
│   ├── fonts
│   ├── ios
│   ├── lib
│   ├── linux
│   ├── macos
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   ├── test
│   ├── web
│   └── windows
├── output.md
├── specification.md
└── todo.md

```

## 前端

使用Flutter构建前端。

## 检测

通过在本机启动通过Flask代理的detect检测的后端服务，来调用摄像头，对获取到的画面使用media_pipe对人体结构进行分析。

## 服务器后端

在服务器端使用Django代理服务，来完成用户数据的管理。

## 使用方法

在detect文件夹下执行
```bash
python app.py
```
即可在 http://127.0.0.1:5000 提供API服务

在flutter文件夹下执行
```bash
flutter run -d windows
```
即可运行flutter前端应用

## 理论指导

使用电脑的坐姿 

1. https://www.uclahealth.org/safety/ergonomics/office-ergonomics/good-posture
2. https://ergonomictrends.com/proper-sitting-posture-computer-experts/

