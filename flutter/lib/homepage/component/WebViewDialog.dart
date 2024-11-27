import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, // 设置背景颜色为白色
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        color: Colors.white, // 设置背景颜色为白色 ?
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
                onPressed: () {
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
