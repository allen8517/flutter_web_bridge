// Dart 与 JS 通信桥接，支持消息发送与监听
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';

enum MessagePriority {
  realtime, // 立即发送（如控制指令）
  normal, // 节流发送（如状态更新）
  background // 存储转发（如日志数据）
}

/// WebviewBridge 用于 Flutter Web 与 JS 进行消息通信
class WebviewBridge {
  /// 单例实例
  static final WebviewBridge _instance = WebviewBridge._internal();

  /// 工厂构造函数，返回单例
  factory WebviewBridge() => _instance;

  WebviewBridge._internal();

  Function(dynamic)? _onMessageCallback;

  /// 监听来自 JS 的消息流
  Stream<Map<String, dynamic>> get onMessage => _onMessageController.stream;

  /// 内部消息控制器
  final StreamController<Map<String, dynamic>> _onMessageController =
      StreamController.broadcast();

  bool _hasInit = false;
  static int _lastFallbackTimestamp = 0;
  static Timer? _throttleTimer;
  static dynamic _pendingData;

  /// 初始化监听，只需调用一次
  void init({void Function(dynamic)? onMessage}) {
    // 避免重复监听
    if (_hasInit) return;
    debugPrint('WebviewBridge init');
    _hasInit = true;
    _onMessageCallback = onMessage;
    html.window.onMessage.listen((html.MessageEvent event) {
      final data = event.data;
      if (data is String) {
        try {
          final Map<String, dynamic> message = jsonDecode(data);
          debugPrint('WebviewBridge onMessage: $message');
          _onMessageCallback != null
              ? _onMessageCallback?.call(message)
              : _onMessageController.add(message);
        } catch (e) {
          // 非 JSON 消息忽略
          debugPrint('WebviewBridge onMessage: ${e.toString()}');
        }
      }
    });
    html.window.onStorage.listen((html.StorageEvent event) {
      debugPrint('''WebviewBridge onStorage: \n
          key: ${event.key} \n 
          oldValue: ${event.oldValue} \n 
          newValue: ${event.newValue} \n 
          url: ${event.url} \n 
          storageArea: ${event.storageArea} \n
        ''');
      if (event.key == 'dataSync') {
        final data = jsonDecode(event.newValue ?? '{}');
        debugPrint('WebviewBridge onStorage: $data');
        if (data['data'] is Map<String, dynamic>) {
          final message = data['data'] as Map<String, dynamic>;
          if (message['timestamp'] != null) {
            if (message['timestamp'] > _lastFallbackTimestamp) {
              _lastFallbackTimestamp = message['timestamp'];
              // _onMessageController.add(message['data'])
              // _onMessageController.add(message);
              _onMessageCallback != null
                  ? _onMessageCallback?.call(message)
                  : _onMessageController.add(message);
            }
          } else {
            // _onMessageController.add(message['data']);
            // _onMessageController.add(message);
            _onMessageCallback != null
                ? _onMessageCallback?.call(message)
                : _onMessageController.add(message);
          }
        }
      }
    });

    // Timer.periodic(const Duration(seconds: 2), (_) {
    //   _checkHiddenIframe();
    // });
  }

  void sendWithPriority(dynamic data,
      [MessagePriority priority = MessagePriority.normal]) {
    if (priority == MessagePriority.realtime) {
      _sendImmediately(data);
    } else {
      _throttledSend(data);
    }
  }

  void _sendImmediately(dynamic data) {
    _setProxyItem(data);
  }

  void _throttledSend(dynamic data) {
    _pendingData = data;
    if (_throttleTimer == null || !_throttleTimer!.isActive) {
      _setProxyItem(_pendingData);
      _pendingData = null;
      _throttleTimer = Timer(const Duration(seconds: 1), () {
        if (_pendingData != null) {
          _setProxyItem(_pendingData);
          _pendingData = null;
        }
      });
    }
  }

  /// 发送消息到 JS 设置内容
  void _setProxyItem(dynamic message) {
    if (message is String) {
      debugPrint('WebviewBridge -String- executeSendMessage: $message');
      js_util.callMethod(html.window, 'setProxyItem', [message]);
    } else if (message is Map<String, dynamic>) {
      debugPrint('WebviewBridge -Map- executeSendMessage: $message');
      js_util.callMethod(html.window, 'setProxyItem', [jsonEncode(message)]);
    } else if (message is List<dynamic>) {
      debugPrint('WebviewBridge -List- executeSendMessage: $message');
      js_util.callMethod(html.window, 'setProxyItem', [jsonEncode(message)]);
    } else {
      debugPrint('WebviewBridge -Unknown- executeSendMessage: $message');
    }
  }

  /// 发送消息到 JS 发送消息 sendMessage , postMessage
  void _postMessage(dynamic data) {
    js_util.callMethod(html.window, 'sendMessage', [jsonEncode(data)]);
  }

  static void _checkHiddenIframe() {
    debugPrint('checkHiddenIframe');
  }

  /// 关闭消息流
  void dispose() {
    debugPrint('WebviewBridge executeDispose');
    _onMessageController.close();
  }
}
