import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pose_app/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  final String username;
  const SettingPage({Key? key, required this.username}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String sessionId = ''; // 存储当前会话的 session ID
  String name = '暂无'; //先默认“暂无”
  String school = '暂无';
  String gender = '暂无';
  String email = '暂无';
  String age = '暂无';
  String access_token = '';

  bool isReminderEnabled = true;
  bool isLoading = true;

  final Dio _dio = Dio(
    BaseOptions(
      // baseUrl: 'http://118.89.124.30:8080',
      baseUrl: 'http://8.217.68.60',

      //connectTimeout: 5000,
      //receiveTimeout: 3000,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeSessionId(); // 初始化 session ID 并加载用户信息
  }

// 从 SharedPreferences 中加载 accessToken
  Future<void> _initializeSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedSessionId = prefs.getString('sessionId');
      if (storedSessionId == null || storedSessionId.isEmpty) {
        throw Exception('Session ID not found');
      }
      // 更新本地状态
      setState(() {
        sessionId = storedSessionId;
      });

      final storedAccessToken = prefs.getString('accessToken');
      if (storedAccessToken == null || storedAccessToken.isEmpty) {
        throw Exception('Access Token not found');
      }
      // 更新本地状态
      setState(() {
        access_token = storedAccessToken;
      });

      print('before load access_token: $access_token');

      // await _loadProfile(); // 加载用户信息
      await _loadProfileUseAccessToken(); // 加载用户信息
    } catch (e, stackTrace) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法加载会话 ID: $e')),
      );
      // 打印错误详细信息到控制台
      print("Error: $e");
      print("StackTrace: $stackTrace");
    }
  }

  // 调用后端接口加载用户信息
  Future<void> _loadProfile() async {
    try {
      print('Session ID: $sessionId'); // 确认 sessionId 是否为空

      final response = await _dio.get(
        '/user/profile',
        options:
            Options(headers: {'sessionid': sessionId}), // 将 session ID 添加到请求头
      );

      print('Request headers: sessionid=$sessionId');

      // 更新用户信息到本地状态
      setState(() {
        name = response.data['name'] ?? '暂无';
        school = response.data['school'] ?? '暂无';
        gender = response.data['gender'] ?? '暂无';
        email = response.data['email'] ?? '暂无';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载个人信息失败: $e')),
      );
    }
  }

  // 调用后端接口加载用户信息
  Future<void> _loadProfileUseAccessToken() async {
    try {
      print('loading the profile using access token...');
      print('Access Token: $access_token'); // 确认 accessToken 是否为空

      final response = await _dio.get(
        '/user_info',
        options: Options(headers: {
          'Authorization': 'Bearer $access_token', // 在请求头中添加 accessToken
        }), // 将 accessToken 添加到请求头
      );

      print('Request headers: Authorization=Bearer $access_token');

      print('response.data: ${response.data}');

      print('response.data[\'full_name\']: ${response.data['full_name']}');
      print('response.data[\'institution\']: ${response.data['institution']}');
      print('response.data[\'gender\']: ${response.data['gender']}');

      // 更新用户信息到本地状态
      setState(() {
        name = response.data['full_name'] ?? '暂无';
        school = response.data['institution'] ?? '暂无';
        gender = response.data['gender'] ?? '暂无';
        email = response.data['email'] ?? '暂无';
        age = response.data['age']?.toString() ?? '暂无';

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载个人信息失败: $e')),
      );
    }
  }

  // 调用后端接口更新用户信息
  Future<void> _saveProfile(String tempName, String tempSchool,
      String tempGender, String tempAge) async {
    try {
      await _dio.put(
        '/user_info',
        data: {
          'full_name': tempName,
          'institution': tempSchool,
          'gender': tempGender,
          'age': tempAge,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $access_token', // 在请求头中添加 accessToken
        }), // 将 accessToken 添加到请求头
      );
      // 更新本地状态
      setState(() {
        name = tempName;
        school = tempSchool;
        gender = tempGender;
        age = tempAge;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('信息已更新')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新个人信息失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        centerTitle: true,
        backgroundColor: AppColors.deppBeige,
      ),
      backgroundColor: AppColors.beige,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 第一部分：个人信息展示
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '个人信息',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        _buildEditDialog(context),
                                  );
                                },
                                child: const Text(
                                  '编辑',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.warmOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildInfoSection('账号ID', widget.username),
                          _buildInfoSection('姓名', name),
                          _buildInfoSection('学校/公司', school),
                          _buildInfoSection('性别', gender),
                          _buildInfoSection('邮箱', email),
                          _buildInfoSection('年龄', age)
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 第二部分：设置功能展示
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '设置',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListTile(
                            leading: const Icon(Icons.notifications),
                            title: const Text('提醒设置',
                                style: TextStyle(fontSize: 16)),
                            trailing: Switch(
                              value: isReminderEnabled,
                              activeColor: AppColors.warmOrange,
                              onChanged: (value) {
                                setState(() {
                                  isReminderEnabled = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEditDialog(BuildContext context) {
    String tempName = name;
    String tempSchool = school;
    String tempGender = gender;
    String tempAge = age;

    return AlertDialog(
      title: const Text('编辑个人信息'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField('姓名', tempName, (value) {
            tempName = value;
          }),
          _buildTextField('学校/公司', tempSchool, (value) {
            tempSchool = value;
          }),
          _buildTextField('性别', tempGender, (value) {
            tempGender = value;
          }),
          _buildTextField('年龄', tempAge, (value) {
            tempAge = value;
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            _saveProfile(tempName, tempSchool, tempGender, tempAge);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(width: 20),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
