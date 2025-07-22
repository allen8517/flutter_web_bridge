<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

```html
<script>
  function greet(name) {
    return "Hello, " + name + " from JS!";
  }

  function callFlutter(message) {
    if (window.onFlutterMessage) {
      window.onFlutterMessage(message);
    }
  }
</script>
```

```
import 'package:flutter_web_bridge/flutter_web_bridge.dart';

final result = JSBridge.callFunction("greet", ["Allen"]);
print(result); // 输出：Hello, Allen from JS!

```

```dart

JSBridge.exposeToJS("onFlutterMessage", (msg) {
  print("来自 JS 的消息: $msg");
});

```

