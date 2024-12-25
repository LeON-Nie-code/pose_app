import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/config/config.dart';

import 'dart:io';

void logErrorToFile(String message) {
  final file = File('error_log.html');
  try {
    print('write message to file:');
    file.writeAsStringSync(
      '${DateTime.now()}: $message\n',
      // mode: FileMode.write, // 覆盖写入
      flush: true, // 确保立即写入磁盘
    );
  } catch (e) {
    print('Failed to write to file: $e');
  }
}

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({Key? key}) : super(key: key);

  @override
  _RegisterAccountState createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  // 成功对话框
  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('注册成功'),
          content: const Text('欢迎使用！请前往登录页面'),
          backgroundColor: AppColors.beige,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 关闭对话框
                Navigator.pop(context); // 返回登录页面
              },
              child: const Text('返回登录'),
            ),
          ],
        );
      },
    );
  }

  // 失败对话框
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('注册失败'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 关闭对话框
              },
              child: const Text('再试一次'),
            ),
          ],
        );
      },
    );
  }

  // 注册请求
  Future<void> _register() async {
    final String email = emailController.text;
    final String username = usernameController.text;
    final String password = passwordController.text;
    final String phone = phoneController.text;

    if (phone.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        email.isEmpty) {
      showErrorDialog('手机号 邮箱、用户名或密码不能为空！');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      print("Sending POST request to /user/register");
      print(
          "Request body: { username: $username, password: $password, mobile: $phone, email: $email }");

      // 向后端发送请求
      final response = await Dio().post(
        // 'http://118.89.124.30:8080/user/register',
        '${Config.baseUrl}/register_no_code',
        data: {
          "phone_number": email,
          "username": username,
          "password": password,
          "email": email,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        showSuccessDialog();
      } else {
        showErrorDialog(response.data["message"] ?? "注册失败，请稍后再试！");
      }
    } on DioError catch (e) {
      logErrorToFile("DioError response data: ${e.response?.data}");
      print("after logErrorToFile");
      if (e.response != null) {
        print("DioError response data: ${e.response?.data}");
        showErrorDialog("注册失败！${e.response?.data['message'] ?? '未知错误'}");
      } else {
        print("DioError message: ${e.message}");
        showErrorDialog("网络错误：${e.message}");
      }
    } catch (e) {
      print("Unexpected error: $e");
      showErrorDialog("发生未知错误，请稍后再试！");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8),
      body: Center(
        child: SingleChildScrollView(
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
                const Text(
                  '注册账号',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Hei',
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: phoneController,
                  hintText: '手机号',
                  iconPath: 'assets/icons/phone.png',
                  width: fieldWidth,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: emailController,
                  hintText: '邮箱',
                  iconPath: 'assets/icons/lock.png',
                  width: fieldWidth,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: usernameController,
                  hintText: '用户名',
                  iconPath: 'assets/icons/userIcon.png',
                  width: fieldWidth,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: passwordController,
                  hintText: '密码',
                  iconPath: 'assets/icons/lock.png',
                  obscureText: true,
                  width: fieldWidth,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: fieldWidth,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0xFFD08726),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            '注册',
                            style: TextStyle(color: Colors.white, fontSize: 18,fontFamily: 'Hei',),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 返回到登录页面
                  },
                  child: const Text(
                    '已有账号？去登录',
                    style: TextStyle(
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                      fontFamily: 'Hei',
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
        style: TextStyle(
          fontFamily: 'Hei',
        ),
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


// import 'package:flutter/material.dart';

// class RegisterAccount extends StatefulWidget {
//   const RegisterAccount({Key? key}) : super(key: key);

//   @override
//   _RegisterAccountState createState() => _RegisterAccountState();
// }

// class _RegisterAccountState extends State<RegisterAccount> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController codeController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final double fieldWidth = MediaQuery.of(context).size.width * 0.8;

//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFCF8),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.shade300,
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   '注册账号',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // 邮箱输入框
//                 _buildTextField(
//                   controller: emailController,
//                   hintText: ' 手机号',
//                   iconPath: 'assets/icons/phone.png', // 使用自定义图标
//                   width: fieldWidth,
//                 ),
//                 const SizedBox(height: 10),

//                 // 用户名输入框
//                 _buildTextField(
//                   controller: usernameController,
//                   hintText: '用户名',
//                   iconPath: 'assets/icons/userIcon.png', // 使用自定义图标
//                   width: fieldWidth,
//                 ),
//                 const SizedBox(height: 10),

//                 // 密码输入框
//                 _buildTextField(
//                   controller: passwordController,
//                   hintText: '密码',
//                   iconPath: 'assets/icons/lock.png', // 使用自定义图标
//                   obscureText: true,
//                   width: fieldWidth,
//                 ),
//                 const SizedBox(height: 10),

//                 // 验证码输入框和获取验证码按钮
//                 SizedBox(
//                   width: fieldWidth, // 保证整体宽度与其他输入框一致
//                   child: Row(
//                     children: [
//                       // 验证码输入框
//                       Expanded(
//                         flex: 2,
//                         child: _buildTextField(
//                           controller: codeController,
//                           hintText: '验证码',
//                           iconPath: 'assets/icons/get.png', // 使用自定义图标
//                         ),
//                       ),
//                       const SizedBox(width: 10), // 间距
//                       // 获取验证码按钮
//                       Expanded(
//                         flex: 1,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // 处理获取验证码过程，暂时不添加
//                           },
//                           style: ElevatedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             backgroundColor: Colors.grey.shade700,
//                           ),
//                           child: const Text(
//                             '获取验证码',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // 注册按钮
//                 SizedBox(
//                   width: fieldWidth,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // 处理注册逻辑
//                     },
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       backgroundColor: const Color(0xFFD08726),
//                     ),
//                     child: const Text(
//                       '注册',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // 已有账号？去登录
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context); // 返回登录页面
//                   },
//                   child: const Text(
//                     '已有账号？去登录',
//                     style: TextStyle(
//                       color: Colors.black54,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hintText,
//     required String iconPath,
//     bool obscureText = false,
//     double? width,
//   }) {
//     return SizedBox(
//       width: width,
//       child: TextField(
//         controller: controller,
//         obscureText: obscureText,
//         decoration: InputDecoration(
//           prefixIcon: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Image.asset(iconPath, width: 24, height: 24),
//           ),
//           hintText: hintText,
//           filled: true,
//           fillColor: Colors.grey.shade100,
//           contentPadding: const EdgeInsets.only(left: 16, bottom: 12),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey.shade500),
//           ),
//         ),
//       ),
//     );
//   }
// }