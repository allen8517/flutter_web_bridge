import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_bridge/src/js_bridge.dart';

void main() {
  test('adds one to input values', () {
    final result = JSBridge.callFunction("onFlutterMessage", ["Allen"]);
    JSBridge.exposeToJS("onFlutterMessage", (msg) {
      print("来自 JS 的消息: $msg");
    });
    print(result); // 输出：Hello, Allen from JS!
  });
}
