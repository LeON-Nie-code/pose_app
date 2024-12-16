import pytest
from io import BytesIO
from app import create_app
from flask_jwt_extended import create_access_token

@pytest.fixture
def client():
    app = create_app("testing")  # 使用测试配置初始化 Flask 应用
    with app.test_client() as client:
        with app.app_context():
            yield client

def test_create_post(client):
    # 创建测试用户的 access token
    access_token = create_access_token(identity=1)  # 假设用户 ID 为 1

    # 构造请求数据
    data = {
        "title": "Test Post",
        "content": "This is a test post content."
    }

    # 构造文件数据
    files = {
        "photo1": (BytesIO(b"image data 1"), "C:\Users\magic\Pictures\cs\1.jpg"),
        "photo2": (BytesIO(b"image data 2"), "C:\Users\magic\Pictures\cs\2.jpg"),
    }

    # 发送请求
    response = client.post(
        "/post",
        data=data,
        content_type='multipart/form-data',
        headers={"Authorization": f"Bearer {access_token}"},
        files=files
    )

    # 检查响应
    assert response.status_code == 201
    assert response.get_json()["message"] == "Post created successfully!"
