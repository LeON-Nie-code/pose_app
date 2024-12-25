import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:pose_app/config/config.dart';

class VideoWebViewDialog extends StatefulWidget {
  final String videoUrl;

  VideoWebViewDialog({required this.videoUrl});

  @override
  _VideoWebViewDialogState createState() => _VideoWebViewDialogState();
}

class _VideoWebViewDialogState extends State<VideoWebViewDialog> {
  late WebviewController _controller;
  bool _isWebViewInitialized = false;
  double dialogWidth = 800; // 初始宽度
  double dialogHeight = 600; // 初始高度

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

//     await _controller.executeScript('''
//     document.body.style.backgroundColor = 'white'; // 设置整个页面的背景为白色
//     var videos = document.getElementsByTagName('video');
//     for (var i = 0; i < videos.length; i++) {
//         videos[i].style.backgroundColor = 'white'; // 设置视频区域的背景为白色
//         videos[i].style.objectFit = 'contain'; // 确保视频按比例显示并留白
//     }
// ''');
//     await _controller.executeScript('''
//     var videos = document.getElementsByTagName('video');
//     for (var i = 0; i < videos.length; i++) {
//         videos[i].style.objectFit = 'contain';
//         videos[i].style.backgroundColor = 'white';
//     }
// ''');

    setState(() {
      dialogWidth = 615;
      dialogHeight = 510;
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

      if (response.data['duration'] != null) {
        print('Duration: ${response.data['duration']}');
        if (response.data['duration'] < 10) {
          print('Duration is less than 10 seconds');

          // 如果会话持续时间小于10秒，则不插入记录
          // 并显示警告消息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('专注时间太短，此次活动不会被记录'),
            ),
          );

          return;
        }
      }

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
        '${Config.baseUrl}/insert_record',
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
        width: dialogWidth,
        height: dialogHeight,
        // width: 600,
        // height: 500,
        margin: EdgeInsets.zero, // 清除外部边距
        padding: EdgeInsets.zero, // 清除内部边距
        color: Colors.white, // 设置整个容器背景为白色
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
