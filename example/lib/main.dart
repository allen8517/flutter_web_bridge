import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_bridge/flutter_web_bridge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'flutter_web_bridge Example',
      home: WebBridgeDemo(),
    );
  }
}

class WebBridgeDemo extends StatefulWidget {
  const WebBridgeDemo({super.key});
  @override
  State<WebBridgeDemo> createState() => _WebBridgeDemoState();
}

class _WebBridgeDemoState extends State<WebBridgeDemo> {
  String _messageFromJS = '';
  String _resultFromJS = '';

  @override
  void initState() {
    super.initState();
    // 暴露 Dart 方法给 JS 调用
    JSBridge.exposeToJS('onJSMessage', (msg) {
      print('onJSMessage: $msg');
      setState(() {
        _messageFromJS = msg.toString();
      });
      return jsonEncode({'name': 'Allen', 'age': 18});
    });
  }

  void _callJS() async {
    // 调用 JS 的 onJSMessage
    final result = await JSBridge.callFunction('onJSMessage', ['Allen']);
    print('result: $result');
    print('result: ${result.runtimeType}');

    setState(() {
      _resultFromJS = result.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_web_bridge Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _callJS,
              child: const Text('调用 JS 函数'),
            ),
            Text('JS 返回: $_resultFromJS'),
            const SizedBox(height: 20),
            Text('收到 JS 主动消息: $_messageFromJS'),
          ],
        ),
      ),
    );
  }
}
