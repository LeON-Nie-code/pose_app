
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 控制用户名和密码输入框的文本控制器
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoginFailed = false; // 登录失败的状态标志
  String loginStateHintText = ""; // 登录状态提示文字

  // 登录函数
  Future<void> login() async {
    final username = usernameController.text; // 获取用户名
    final password = passwordController.text; // 获取密码

    // 检查用户名和密码是否为空
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        isLoginFailed = true; // 设置登录失败状态
        loginStateHintText = "用户名或密码不能为空"; 
      });
      return;
    }

    // 模拟登录成功后的操作
    setState(() {
      isLoginFailed = false; // 设置登录成功状态
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const HomePage()), // 跳转到主页（HomePage 组件）
                //由于目前还没有创建关于主页的文件，暂时连到这个文件底部的class HomePage extends StatelessWidget 部分
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.8; 

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8), 
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), 
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, 
                blurRadius: 10, 
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 用户名输入框
              _buildTextField(
                controller: usernameController,
                hintText: '用户名',
                icon: Icons.person,
                width: fieldWidth,
              ),
              const SizedBox(height: 10), 
              // 密码输入框
              _buildTextField(
                controller: passwordController,
                hintText: '密码',
                icon: Icons.lock,
                obscureText: true, // 隐藏密码输入
                width: fieldWidth,
              ),
              const SizedBox(height: 20),
              // 登录按钮
              SizedBox(
                width: fieldWidth,
                child: ElevatedButton(
                  onPressed: login, 
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                    ),
                    backgroundColor: Colors.grey.shade700, 
                  ),
                  child: const Text(
                    '登录',
                    style: TextStyle(color: Colors.white, fontSize: 18), 
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // "忘记密码" 和 "新用户注册" 按钮
              SizedBox(
                width: fieldWidth, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    // 忘记密码按钮
                    TextButton(
                      onPressed: () {}, 
                      child: const Text(
                        '忘记密码？',
                        style: TextStyle(
                          color: Colors.black54,
                          decoration: TextDecoration.underline, 
                        ),
                      ),
                    ),
                    // 新用户注册按钮
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register'); // 跳转到注册页面
                      },
                      child: const Text(
                        '新用户注册',
                        style: TextStyle(
                          color: Colors.black54,
                          decoration: TextDecoration.underline, 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 其他登录方式
              _buildOtherLoginMethods(),
            ],
          ),
        ),
      ),
    );
  }

  // 创建输入框的组件函数
  Widget _buildTextField({
    required TextEditingController controller, 
    required String hintText, 
    required IconData icon, 
    bool obscureText = false, 
    required double width, 
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey), 
          hintText: hintText, 
          filled: true,
          fillColor: Colors.grey.shade100, 
          contentPadding: const EdgeInsets.only(left: 16, bottom: 12), 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), 
            borderSide: BorderSide(color: Colors.grey.shade300), 
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), 
            borderSide: BorderSide(color: Colors.grey.shade500), 
          ),
        ),
      ),
    );
  }

  // 其他登录方式组件
  Widget _buildOtherLoginMethods() {
    return Column(
      children: [
        const Text(
          '其他登录方式',
          style: TextStyle(color: Colors.grey, fontSize: 14), 
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            // 微信登录图标按钮
            IconButton(
              icon: const Icon(Icons.wechat, size: 40),
              onPressed: () {},
            ),
            const SizedBox(width: 40), 
            // 手机登录图标按钮
            IconButton(
              icon: const Icon(Icons.phone_android, size: 40),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

// 暂时用于模拟登录成功后的跳转页面
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('主页')), 
      body: const Center(
        child: Text('欢迎登录成功！'), 
      ),
    );
  }
}
