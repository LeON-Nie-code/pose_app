import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoDialog extends StatelessWidget {
  const VideoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("视频流"),
      content: Container(
        width: 600,
        height: 400,
        child: VideoStream(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("关闭"),
        ),
      ],
    );
  }
}

class VideoStream extends StatefulWidget {
  @override
  _VideoStreamState createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  late http.Client _httpClient;
  late Stream<List<int>> _videoStream = Stream.empty();
  String _errorMessage = ''; // 错误信息
  bool _isError = false; // 错误标识

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _startVideoStream();
  }

  // 启动视频流
  void _startVideoStream() async {
    final Uri videoFeedUrl = Uri.parse('http://127.0.0.1:5000/video_feed');

    try {
      final request = http.Request('GET', videoFeedUrl);
      final response = await _httpClient.send(request);

      // 打印响应状态码
      print('Response status: ${response.statusCode}');

      List<int> _frameData = [];

      // 如果响应成功（状态码200），开始处理视频流
      if (response.statusCode == 200) {
        print('Successfully connected to the video feed.');
        _videoStream = response.stream.asyncMap((data) {
          _frameData.addAll(data);
          print("Received ${data.length} bytes of data");
          // print("data: $_frameData");
          int startIndex = _frameData.indexOf(0xffd8);
          int endIndex = _frameData.indexOf(0xffd9, startIndex);
          if (startIndex != -1 && endIndex != -1) {
            // 提取完整的 JPEG 图像
            print("Extracting frame from index $startIndex to $endIndex");
            final frame = _frameData.sublist(startIndex, endIndex + 1);
            print("data: $frame");
            _frameData.clear(); // 清空缓存
            return frame;
          }
          print("No frame found");
          return [];
        });
        setState(() {
          _isError = false;
        });
      } else {
        // 如果状态码不是200，设置错误信息
        print(
            'Failed to load video stream. Status code: ${response.statusCode}');
        setState(() {
          _isError = true;
          _errorMessage =
              'Failed to load video stream. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      // 捕获任何异常，并显示错误信息
      print('Error while fetching video stream: $e');
      setState(() {
        _isError = true;
        _errorMessage = 'Error while fetching video stream: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Center(child: Text(_errorMessage)); // 显示错误信息
    }

    return StreamBuilder<List<int>>(
      stream: _videoStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('加载视频流失败'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('视频流为空'));
        }

        // 将 List<int> 转换为 Uint8List
        final bytes = Uint8List.fromList(snapshot.data!);

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}
