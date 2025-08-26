import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewTest extends StatefulWidget {
  const WebViewTest({Key? key}) : super(key: key);

  @override
  State<WebViewTest> createState() => _WebViewTestState();
}

class _WebViewTestState extends State<WebViewTest> {
  late WebViewController _controller;

  // String url="http://c.hiphotos.baidu.com/image/pic/item/30adcbef76094b36de8a2fe5a1cc7cd98d109d99.jpg";
  String url="https://picsum.photos/400/400?random=1";
  // String url = "https://www.baidu.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: url,
        onWebViewCreated: (controller) =>
            _controller = controller,
        onProgress: (progress) => print(progress),
        javascriptMode: JavascriptMode.unrestricted,
        onPageStarted: (url) =>
            print('start loading: $url'),
        onPageFinished: (url) {
          print('load finished:$url');
          _controller.runJavascript(
              ''' setTimeout(function() { Toaster.postMessage("来自注入JS的消息，延迟3秒后显示"); }, 3000); ''');
        },
        onWebResourceError: (err) =>
            print('resource error:${err.description}'),
        javascriptChannels: <JavascriptChannel>{
          _toasterJavascriptChannel(context),
        },
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(
      BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      },
    );
  }
}
