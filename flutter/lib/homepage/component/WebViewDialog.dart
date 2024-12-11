import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_windows/webview_windows.dart';

class VideoWebViewDialog extends StatefulWidget {
  final String videoUrl;

  VideoWebViewDialog({required this.videoUrl});

  @override
  _VideoWebViewDialogState createState() => _VideoWebViewDialogState();
}

class _VideoWebViewDialogState extends State<VideoWebViewDialog> {
  late WebviewController _controller;
  bool _isWebViewInitialized = false;

  @override
  void initState() {
    super.initState();
    // 初始化 WebView 控制器
    _controller = WebviewController();
    _initializeWebView();
  }

  // 初始化 WebView，加载视频流
  Future<void> _initializeWebView() async {
    await _controller.initialize();
    await _controller.loadUrl(widget.videoUrl); // 加载视频流的 URL
    setState(() {
      _isWebViewInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getSessionRecord() async {
    try {
      Dio dio = Dio();
      Response response = await dio.get(
        'http://127.0.0.1:5000/session_record',
      );
      print('Session Record: ${response.data}');
      // 将response.data作为JSON数据传递给POST请求
      await insertRecord(response.data);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> insertRecord(dynamic sessionData) async {
    final prefs = await SharedPreferences.getInstance();
    final storedAccessToken = prefs.getString('accessToken');
    if (storedAccessToken == null || storedAccessToken.isEmpty) {
      throw Exception('Access Token not found');
    }
    // 更新本地状态
    final access_token = storedAccessToken;

    print(' access_token in WebViewDialog: $access_token');
    try {
      Dio dio = Dio();
      dio.interceptors.add(LogInterceptor(
        request: true, // 是否打印请求日志
        responseBody: true, // 是否打印响应日志
        error: true, // 是否打印错误日志
        requestHeader: true, // 是否打印请求头
        responseHeader: true, // 是否打印响应头
      ));

      // 确保sessionData是Map类型，如果不是，需要转换
      Map<String, dynamic> data = sessionData;
      print('Data: $data');
      Response response = await dio.post(
        'http://8.217.68.60/insert_record',
        data: data,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access_token', // 在请求头中添加 accessToken
        }), // 将 accessToken 添加到请求头
      );
      print('Insert Record Response: ${response.data}');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 800,
        height: 600,
        child: Column(
          children: [
            // 只有在 WebView 初始化后才显示
            _isWebViewInitialized
                ? Expanded(
                    child: Webview(
                      _controller,
                    ),
                  )
                : Center(child: CircularProgressIndicator()), // 加载时显示进度指示器
            // 关闭按钮
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await getSessionRecord(); // 发送 POST 请求
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
