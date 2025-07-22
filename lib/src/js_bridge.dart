import 'dart:js' as js;
import 'dart:js_util' as js_util;

/// Flutter 与 JS 的桥接工具类
class JSBridge {
  /// 调用 JS 函数（带参数）
  static dynamic callFunction(String functionName, [List<dynamic>? args]) {
    final jsFunction = js.context[functionName];
    if (jsFunction == null) {
      throw Exception("JS function '$functionName' not found.");
    }
    return js_util
        .callMethod(jsFunction, 'call', [js.context, ...(args ?? [])]);
  }

  /// 注册 Dart 函数到 JS 全局变量（让 JS 调用 Dart）
  static void exposeToJS(String name, Function function) {
    js.context[name] = js.allowInterop(function);
  }
}
