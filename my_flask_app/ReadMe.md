# 项目名称

对您的项目进行简要描述。

## 目录

1. [环境准备](#环境准备)
2. [安装指南](#安装指南)
3. [运行应用](#运行应用)
4. [使用 Gunicorn 运行](#使用-gunicorn-运行)
5. [后台运行](#后台运行)

## 环境准备

确保您的系统中已安装 Python 3。

## 安装指南

1. 克隆仓库：
   ```bash
   git clone https://github.com/你的用户名/你的项目.git


## Command

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

python3 app.py



gunicorn -w 4 -b 0.0.0.0:8889 app:app




 


nohup python3 app.py &

netstat -tulnp | grep 8889
sudo lsof -i :8889

