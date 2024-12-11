import os

class Config:
    SQLALCHEMY_DATABASE_URI = 'sqlite:///site.db'  # 使用 SQLite 数据库
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SECRET_KEY = os.urandom(24)  # 设置密钥用于加密 JWT 和其他安全功能
    JWT_SECRET_KEY = os.urandom(24)  # 用于生成 JWT
