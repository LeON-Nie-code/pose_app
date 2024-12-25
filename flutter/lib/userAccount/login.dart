import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pose_app/homepage/homepage.dart' as homepage;
import 'package:pose_app/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  String currentIcon = 'assets/icons/userIcon.png';
  String hintText = '用户名';
  String loginEndpoint = '/login_username'; //

  // 显示登录成功弹框并自动跳转到主页
  void _showLoginSuccessDialog(String username) {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止手动关闭弹框
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '登录成功！',
            style: TextStyle(
              fontFamily: 'Gen-light',
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            '欢迎回来',
            style: TextStyle(
              fontFamily: 'Gen-light',
              fontWeight: FontWeight.w800,
            ),
          ),
          backgroundColor: AppColors.beige,
        );
      },
    );

    // 2秒后关闭弹框并跳转到主页
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context); // 关闭弹框
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => homepage.HomePage(username: username),
        ),
      );
    });
  }

  Future<void> _login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "用户名或密码不能为空";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final Map<String, String> loginFieldMap = {
        '用户名': 'username',
        '邮箱': 'email',
        '手机号': 'phone_number',
      };

      final response = await Dio().post(
        'http://8.217.68.60$loginEndpoint',
        data: {
          loginFieldMap[hintText]!: username,
          "password": password,
        },
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );

      // 检查响应状态码
      if (response.statusCode == 200) {
        // 登录成功，提取response 中的accessToken
        final accessToken = response.data['access_token'];
        print('Access Token: $accessToken');

        // 将 accessToken 存储到 SharedPreferences 中，供后续请求使用
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        print('Access Token stored: $accessToken');

        // final rawCookie = response.headers.value('set-cookie') ?? '';
        // print('Raw cookie: $rawCookie'); // 打印原始 cookie 值供调试（在终端中）

        // // 提取 sessionid
        // final sessionId =
        //     RegExp(r'sessionid=([^;]+)').firstMatch(rawCookie)?.group(1);
        // // 如果未能提取到有效的 sessionid，抛出异常
        // if (sessionId == null || sessionId.isEmpty) {
        //   throw Exception('未找到有效的 sessionid');
        // }

        // print('Extracted sessionId: $sessionId');

        // // 将 sessionid 存储到 SharedPreferences 中，供后续请求使用
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('sessionId', sessionId);
        // print('Session ID stored: $sessionId');

        // 登录成功，显示弹框并跳转

        // 登录后获取用户名（用邮箱、手机号注册时还是得返回username）
        await _fetchUsernameAndNavigate(accessToken);
      } else {
        setState(() {
          errorMessage = '登录失败，请检查$hintText和密码。';
        });
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('!!!!!!!!!!!Error Response: ${e.response?.data}');
        setState(() {
          errorMessage = e.response?.data['message'] ?? '登录失败，请检查$hintText和密码。';
        });
      } else
        setState(() {
          errorMessage = '登录失败，请检查$hintText和密码。';
        });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// 调用 /user 接口获取用户名
  Future<void> _fetchUsernameAndNavigate(String accessToken) async {
    try {
      final response = await Dio().get(
        'http://8.217.68.60/user',
        options: Options(headers: {
          "Authorization": "Bearer $accessToken",
        }),
      );

      if (response.statusCode == 200) {
        final String username = response.data['username'];
        print('Fetched Username: $username');
        _showLoginSuccessDialog(username); // 跳转到主页
      } else {
        setState(() {
          errorMessage = '获取用户信息失败，请稍后再试。';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '获取用户信息失败，请稍后再试。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8),
      body: Center(
        child: Container(
          width: 500,
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
                hintText: hintText,
                iconPath: currentIcon,
                width: fieldWidth,
              ),
              const SizedBox(height: 10),
              // 密码输入框
              _buildTextField(
                controller: passwordController,
                hintText: '密码',
                iconPath: 'assets/icons/lock.png',
                obscureText: true,
                width: fieldWidth,
              ),
              const SizedBox(height: 20),
              // 登录按钮
              SizedBox(
                width: fieldWidth,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.grey.shade700,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '登录',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Hei',
                              fontWeight: FontWeight.w400),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              // 错误信息提示
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
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
                      onPressed: () {
                        Navigator.pushNamed(context, '/resetPassword');
                      },
                      child: const Text(
                        '忘记密码？',
                        style: TextStyle(
                          fontFamily: 'Hei',
                          color: Colors.black54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    // 新用户注册按钮
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        '新用户注册',
                        style: TextStyle(
                          fontFamily: 'Hei',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String iconPath,
    bool obscureText = false,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
            fontFamily: 'Hei',
            color: Colors.black,
            fontWeight: FontWeight.w300),
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

  Widget _buildOtherLoginMethods() {
    return Column(
      children: [
        const Text(
          '其他登录方式',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Hei',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon:
                  Image.asset('assets/icons/email.png', width: 40, height: 40),
              onPressed: () {
                // 邮件登录逻辑
                setState(() {
                  currentIcon = 'assets/icons/email.png';
                  hintText = '邮箱';
                  loginEndpoint = '/login_email';
                });
              },
            ),
            const SizedBox(width: 40),
            IconButton(
              icon:
                  Image.asset('assets/icons/phone.png', width: 40, height: 40),
              onPressed: () {
                // 手机登录逻辑
                setState(() {
                  currentIcon = 'assets/icons/phone.png';
                  hintText = '手机号';
                  loginEndpoint = '/login_phone';
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
