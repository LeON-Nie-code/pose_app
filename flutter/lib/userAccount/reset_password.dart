import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController validCodeController = TextEditingController();

  String verificationMethod = '邮箱';
  String hintText = '请输入邮箱';
  bool isCodeSent = false;
  String validCodeSentHintText = "验证码已经发送";

  Future<void> sendVerificationCode() async {
    if (emailOrPhoneController.text.isEmpty) {
      setState(() {
        validCodeSentHintText = "$verificationMethod 不能为空！";
      });
      return;
    }

    setState(() {
      isCodeSent = true;
      validCodeSentHintText = "$verificationMethod 验证码已发送";
    });
  }

  Future<void> resetPassword() async {
    if (newPasswordController.text.isEmpty ||
        validCodeController.text.isEmpty ||
        emailOrPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请填写完整信息")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("重置成功"),
          content: const Text("密码重置成功，请使用新密码登录。"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/');
              },
              child: const Text("返回登录"),
            ),
          ],
        );
      },
    );
  }

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
                  '重置密码',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextFieldWithDropdown(
                  controller: emailOrPhoneController,
                  hintText: hintText,
                  iconPath: verificationMethod == '邮箱'
                      ? 'assets/icons/email.png'
                      : 'assets/icons/phone.png',
                  width: fieldWidth,
                ),

                const SizedBox(height: 10),

                // 新密码输入框
                _buildTextField(
                  controller: newPasswordController,
                  hintText: '新密码',
                  iconPath: 'assets/icons/lock.png', // 使用自定义图标
                  obscureText: true,
                  width: fieldWidth,
                ),
                const SizedBox(height: 10),

                // 验证码输入框和获取验证码按钮，宽度与"新密码"输入框一致
                SizedBox(
                  width: fieldWidth, // 保证整体宽度与其他输入框一致
                  child: Row(
                    children: [
                      // 验证码输入框
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: validCodeController,
                          hintText: '验证码',
                          iconPath: 'assets/icons/get.png', // 使用自定义图标
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 获取验证码按钮
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: sendVerificationCode,
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

                const SizedBox(height: 10),

                if (isCodeSent)
                  Text(
                    validCodeSentHintText,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),

                const SizedBox(height: 20),

                // 添加“返回登录”按钮
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 返回登录页面
                  },
                  child: const Text(
                    '返回登录',
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

  Widget _buildTextFieldWithDropdown({
    required TextEditingController controller,
    required String hintText,
    required String iconPath,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
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
          suffixIcon: _buildDropdownMenu(),
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

  Widget _buildDropdownMenu() {
    return DropdownButton<String>(
      value: verificationMethod,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(),
      onChanged: (String? newValue) {
        setState(() {
          verificationMethod = newValue!;
          hintText = newValue == '邮箱' ? '请输入邮箱' : '请输入手机号';
        });
      },
      items: <String>['邮箱', '手机号']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
