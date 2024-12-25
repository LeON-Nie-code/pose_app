# 项目名称

对您的项目进行简要描述。

## 目录

- [项目名称](#项目名称)
  - [目录](#目录)
  - [环境准备](#环境准备)
  - [安装指南](#安装指南)
  - [运行应用](#运行应用)
    - [使用-gunicorn-运行](#使用-gunicorn-运行)
    - [后台运行](#后台运行)
    - [docker运行](#docker运行)
  - [调试命令](#调试命令)
  
## 环境准备

确保您的系统中已安装 Python 3。

## 安装指南

克隆仓库：

```bash
git clone https://github.com/LeON-Nie-code/pose_app.git
```

## 运行应用

```bash
cd my_flask_app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 app.py
```

### 使用-gunicorn-运行

```bash
gunicorn -w 4 -b 0.0.0.0:8889 app:app
```

### 后台运行

在后台运行，并输出到nohup.out文件中

```bash
nohup python3 app.py &
```

### docker运行

```bash
docker-compose build
docker-compose up
```


## 调试命令

```bash
netstat -tulnp | grep 8889
sudo lsof -i :8889
```

