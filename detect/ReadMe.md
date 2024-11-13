# Pose Detection API - README

## 项目简介

该项目是一个基于 Flask 和 MediaPipe 实现的人体姿态检测应用，能够通过摄像头捕捉视频流并实时检测人体姿态。应用使用 MediaPipe 的 Pose 模块来进行姿态识别，并通过 Flask 提供 API 接口。项目支持多种姿态监控功能，如歪头、低头、侧脸监控等。

## 主要功能

1. **视频流显示**：能够捕获摄像头视频流并进行实时姿态检测。
2. **姿态监控**：通过检测不同的身体部位之间的角度和位置，来判断是否存在低头、歪头、撑桌等姿态问题。
3. **摄像头选择**：支持选择使用的摄像头。
4. **API接口**：提供 RESTful API 接口，便于与前端进行交互。

## 依赖

- Flask
- Flask-CORS
- OpenCV
- MediaPipe
- threading
- math

## 安装与运行

### 1. 克隆项目

```bash
git clone https://github.com/LeON-Nie-code/pose_app.git
cd pose_app
```

### 2. 安装依赖


```bash
pip install -r requirements.txt

```

### 3. 启动应用

pip install -r requirements.txt
```bash
python app.py
```

应用将在 http://0.0.0.0:5000 启动。
### 4. 访问 API

使用浏览器或 API 测试工具（如 Postman）访问以下接口。
## API 说明
### 1. GET /cameras

描述：获取当前设备上所有可用的摄像头索引。

响应示例：

```json
{
  "cameras": [0, 1, 2]
}
```


cameras 数组包含所有可用摄像头的索引。
### 2. POST /select_camera

描述：选择要使用的摄像头。传入摄像头的索引值，应用将切换到该摄像头。

请求示例：

```json
{
  "index": 0
}
```



响应示例：

```json
{
  "status": "success",
  "camera_index": 0
}
```


参数：

    index：要选择的摄像头索引。

### 3. GET /video_feed

描述：获取摄像头视频流，并实时显示姿态检测的结果。

响应：该接口返回一个 MJPEG 流，其中每一帧都包含姿态检测的结果。
### 4. all_detection 函数

描述：该函数接受来自 MediaPipe 识别到的关键点（如左耳、右耳、鼻子等）的坐标，并根据预设的判断条件来输出姿态状态（如歪头、低头等）。
主要监控功能

以下是 all_detection 函数监控的一些姿态状态及其描述：

    歪头监控：根据左耳和右耳的角度判断是否存在歪头姿势。
    低头监控：根据左嘴角和左肩膀的角度判断是否存在低头姿势。
    侧脸监控：根据左眼内和右耳的坐标判断是否为左侧脸或右侧脸。
    高低肩监控：根据左右肩膀的位置判断是否存在高低肩姿势。
    撑桌监控：根据嘴角和肩膀的位置判断是否存在撑桌行为。
    仰头监控：根据鼻子和左耳的角度判断是否存在仰头姿势。
    趴桌监控：根据肩膀的归一化 y 坐标判断是否存在趴桌行为。

## 代码结构

pose_app/
│
├── app.py               # 主程序，Flask 服务和视频流处理
├── detect/              # 存放姿态检测相关的文件
│   └── utils.py         # 包含姿态监控功能的函数
├── requirements.txt     # 项目依赖列表
└── README.md            # 项目说明文件

    app.py: Flask 主程序，负责初始化 Web 服务、处理视频流和提供 API 接口。
    detect/utils.py: 包含姿态检测的核心函数，all_detection 函数用于根据关键点坐标判断用户的姿势状态。

## 注意事项

    本应用需要访问设备的摄像头，因此在运行时请确保摄像头已正确连接并能正常使用。
    若在不同设备或环境中运行，可能需要调整 MediaPipe 和 OpenCV 的配置，确保视频流和姿态检测功能正常。
