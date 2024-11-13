import 'package:flutter/material.dart';
import 'userAccount/login.dart'; 
import 'userAccount/register.dart';
import 'userAccount/reset_password.dart';
import 'homepage/homepage.dart';  

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // 初始路由设置为登录页面
      routes: {
        '/': (context) => const LoginPage(), // 登录页面
        '/register': (context) => const RegisterAccount(), // 注册页面
        '/resetPassword': (context) => const ResetPasswordPage(), // 重置密码页面
        '/home': (context) => const HomePage(), // 主页页面
      },
    );
  }
}
