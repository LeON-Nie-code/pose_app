import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class VideoDialog extends StatelessWidget {
  const VideoDialog({Key? key}) : super(key: key);

  // 连接视频流 API
  Stream<List<int>> fetchVideoStream() async* {
    final uri = Uri.parse('http://127.0.0.1:5000/video_feed'); // Flask API 地址

    var client = http.Client();
    var request = http.Request('GET', uri);
    var response = await client.send(request);

    // 处理多部分流数据
    List<int> currentData = [];
    await for (var chunk in response.stream) {
      currentData.addAll(chunk);

      // 查找图像数据的起始和结束边界（--frame）
      int start = 0;
      while (start < currentData.length) {
        // 查找图像数据开始标记
        int boundaryStart =
            currentData.indexOf(0x2D, start); // 0x2D 是 '-' 的 ASCII 值
        if (boundaryStart != -1 && currentData.length > boundaryStart + 5) {
          // 确保我们有 '--frame' 开始的边界标记
          if (currentData[boundaryStart + 1] == 0x66 &&
              currentData[boundaryStart + 2] == 0x72 &&
              currentData[boundaryStart + 3] == 0x61 &&
              currentData[boundaryStart + 4] == 0x6D) {
            start = boundaryStart + 5; // 跳过 '--frame' 和换行符
            continue;
          }
        }

        // 查找图像数据结束标记 (JPEG 图像的结束标记 0xFFD9)
        int endIndex = currentData.indexOf(0xFF, start);
        if (endIndex != -1 && currentData[endIndex + 1] == 0xD9) {
          List<int> imageData =
              currentData.sublist(start, endIndex + 2); // 提取 JPEG 图像数据

          // 处理图像数据
          img.Image? frame = img.decodeImage(Uint8List.fromList(imageData));
          if (frame != null) {
            yield imageData; // 将图像数据发送给 StreamBuilder
          }

          // 更新数据指针，跳到下一个图像开始位置
          currentData = currentData.sublist(endIndex + 2);
          start = 0; // 继续处理剩余的数据
        } else {
          break; // 没有找到结束标记，继续接收更多数据
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Video Feed'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: StreamBuilder<List<int>>(
          stream: fetchVideoStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching video stream'));
            }

            if (snapshot.hasData) {
              List<int> data = snapshot.data!;
              print('Received data length: ${data.length}');
              img.Image? frame = img.decodeImage(Uint8List.fromList(data));

              if (frame != null) {
                return Image.memory(Uint8List.fromList(img.encodeJpg(frame)));
              } else {
                return const Center(child: Text('Invalid frame data'));
              }
            }

            return const Center(child: Text('No data'));
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

void showVideoStreamDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const VideoDialog();
    },
  );
}
