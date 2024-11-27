import 'package:flutter/material.dart';
import 'package:pose_app/style/colors.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // 临时保存的个人信息变量
  String name = '金民周';
  String school = '清华大学';
  String gender = '女';
  String accountId = '42557833';
  String email = 'jinm*****u0000@gmail.com';
  String phoneNumber = '111111111111';

  bool isReminderEnabled = true; // 用于提醒设置的开关状态

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        centerTitle: true,
        backgroundColor: AppColors.deppBeige,
      ),
      backgroundColor: AppColors.beige,
      body: SingleChildScrollView(
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
                              builder: (context) => _buildEditDialog(context),
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
                    _buildInfoSection('姓名', name),
                    _buildInfoSection('学校/公司', school),
                    _buildInfoSection('性别', gender),
                    _buildInfoSection('账号ID', accountId),
                    _buildInfoSection('邮箱', email),
                    _buildInfoSection('手机号', phoneNumber),
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

                    // 提醒设置
                    Container(
                      child: ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text(
                          '提醒设置',
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Switch(
                          value: isReminderEnabled,
                          activeColor: AppColors.warmOrange, // 开启时的开关颜色
                          inactiveThumbColor: Colors.grey, // 关闭时的开关颜色
                          inactiveTrackColor:
                              Colors.grey.withOpacity(0.4), // 轨道关闭时颜色
                          onChanged: (value) {
                            setState(() {
                              isReminderEnabled = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const Divider(),

                    // 使用指南
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text(
                        '使用指南',
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // 跳转到使用指南页面或弹窗
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('使用指南'),
                            content: const Text(
                              '正在准备',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('关闭'),
                              ),
                            ],
                          ),
                        );
                      },
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

  // 编辑对话框（临时保存）
  Widget _buildEditDialog(BuildContext context) {
    String tempName = name;
    String tempSchool = school;
    String tempGender = gender;
    String tempEmail = email;
    String tempPhoneNumber = phoneNumber;


    return AlertDialog(
      title: const Text('编辑个人信息'),
      backgroundColor: AppColors.beige,
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
          _buildTextField('邮箱', tempEmail, (value) {
            tempEmail = value;
          }),
          _buildTextField('手机号', tempPhoneNumber, (value) {
            tempPhoneNumber = value;
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
            setState(() {
              name = tempName;
              school = tempSchool;
              gender = tempGender;
              email = tempEmail;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('信息已更新')),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  // 文本输入框
  Widget _buildTextField(String label, String initialValue, Function(String) onChanged) {
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

  // 个人信息项
  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 20),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
