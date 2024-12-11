from flask import Flask
from flask_jwt_extended import JWTManager
from models import db, bcrypt
from routes import auth_bp
import config
from flask_migrate import Migrate
from gevent import pywsgi

app = Flask(__name__)

# 配置应用
app.config.from_object(config.Config)

# 初始化扩展
db.init_app(app)
bcrypt.init_app(app)
jwt = JWTManager(app)
migrate = Migrate(app, db)

# 注册路由
app.register_blueprint(auth_bp)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8889, debug=True)
    # server = pywsgi.WSGIServer(('0.0.0.0',8889),app)
    # server.serve_forever()

