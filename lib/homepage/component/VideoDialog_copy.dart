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
  late Stream<List<int>> _videoStream;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _startVideoStream();
  }

  // 启动视频流
  void _startVideoStream() {
    final Uri videoFeedUrl = Uri.parse('http://127.0.0.1:5000/video_feed');
    _videoStream = _httpClient
        .send(http.Request('GET', videoFeedUrl))
        .asStream()
        .asyncMap((response) async {
      // 处理响应流并返回
      return response.stream.toList(); // 将 ByteStream 转换为 List<int>
    }).asyncExpand((data) async* {
      // 处理分段数据并将其合并
      yield* Stream.fromIterable(data);
    });
  }

  @override
  Widget build(BuildContext context) {
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
