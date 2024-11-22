// lib/Communication/communication_page.dart
import 'package:flutter/material.dart';

class CommunicationPage extends StatelessWidget {
  const CommunicationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '朋友圈页面',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}
