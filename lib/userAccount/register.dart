import 'package:flutter/material.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({Key? key}) : super(key: key);

  @override
  _RegisterAccountState createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8),
      body: Center(
        child: SingleChildScrollView(
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
                const Text(
                  '注册账号',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 邮箱输入框
                _buildTextField(
                  controller: emailController,
                  hintText: ' 手机号',
                  iconPath: 'assets/icons/phone.png', // 使用自定义图标
                  width: fieldWidth,
                ),
                const SizedBox(height: 10),

                // 用户名输入框
                _buildTextField(
                  controller: usernameController,
                  hintText: '用户名',
                  iconPath: 'assets/icons/userIcon.png', // 使用自定义图标
                  width: fieldWidth,
                ),
                const SizedBox(height: 10),

                // 密码输入框
                _buildTextField(
                  controller: passwordController,
                  hintText: '密码',
                  iconPath: 'assets/icons/lock.png', // 使用自定义图标
                  obscureText: true,
                  width: fieldWidth,
                ),
                const SizedBox(height: 10),

                // 验证码输入框和获取验证码按钮
                SizedBox(
                  width: fieldWidth, // 保证整体宽度与其他输入框一致
                  child: Row(
                    children: [
                      // 验证码输入框
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: codeController,
                          hintText: '验证码',
                          iconPath: 'assets/icons/get.png', // 使用自定义图标
                        ),
                      ),
                      const SizedBox(width: 10), // 间距
                      // 获取验证码按钮
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            // 处理获取验证码过程，暂时不添加
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.grey.shade700,
                          ),
                          child: const Text(
                            '获取验证码',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 注册按钮
                SizedBox(
                  width: fieldWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      // 处理注册逻辑
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0xFFD08726),
                    ),
                    child: const Text(
                      '注册',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 已有账号？去登录
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 返回登录页面
                  },
                  child: const Text(
                    '已有账号？去登录',
                    style: TextStyle(
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String iconPath,
    bool obscureText = false,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(iconPath, width: 24, height: 24),
          ),
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
}
