import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HttpTestRoute extends StatefulWidget {
  const HttpTestRoute({Key? key}) : super(key: key);

  @override
  _HttpTestRouteState createState() => _HttpTestRouteState();
}

class _HttpTestRouteState extends State<HttpTestRoute> {
  bool _loading = false;
  String _text = "";
  String startTime = "";
  String endTime = "";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ElevatedButton(
            child: const Text("获取百度首页"),
            onPressed: _loading ? null : request,
          ),
          TextButton(onPressed: () {

          }, child: Text('$startTime --> $endTime', style: TextStyle(fontSize: 16.0, color: Colors.blue.shade700))),
          SizedBox(
            width: MediaQuery.of(context).size.width - 50.0,
            child: Text(_text.replaceAll(RegExp(r"\s"), "")),
          ),
        ],
      ),
    );
  }

  // Optimize: 同时注意dart的Future它相当于协程，不会阻塞UI线程，仅仅是这个“域”内等待获取结果
  // Optimize: 验证的话，你看TextButton一直是可以点击的
  request() async {
    setState(() {
      // 获取当前时间
      startTime = DateFormat('HH:mm:ss').format(DateTime.now());
      _loading = true;
      _text = "正在请求...";
    });
    try {
      await Future.delayed(Duration(seconds: 3));
      //创建一个HttpClient
      HttpClient httpClient = HttpClient();
      //打开Http连接
      HttpClientRequest request =
          await httpClient.getUrl(Uri.parse("https://www.baidu.com"));
      //使用iPhone的UA
      request.headers.add(
        "user-agent",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1",
      );
      //等待连接服务器（会将请求信息发送给服务器）
      HttpClientResponse response = await request.close();
      //读取响应内容
      _text = await response.transform(utf8.decoder).join();
      //输出响应头
      print(response.headers);

      //关闭client后，通过该client发起的所有请求都会中止。
      httpClient.close();
    } catch (e) {
      _text = "请求失败：$e";
    } finally {
      // Optimize: 最终刷新一下是很关键，并且上面的异步操作都采用了await（相当于join等结果，直到一步步最后到这里时一定是有结果的，成功or失败）
      setState(() {
        endTime = DateFormat('HH:mm:ss').format(DateTime.now());
        _loading = false;
      });
    }
  }
}
