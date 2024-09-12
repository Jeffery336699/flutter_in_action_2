import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketRoute extends StatefulWidget {
  const WebSocketRoute({Key? key}) : super(key: key);

  @override
  _WebSocketRouteState createState() => _WebSocketRouteState();
}

class _WebSocketRouteState extends State<WebSocketRoute> {
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel channel;
  String _text = '';

  @override
  void initState() {
    super.initState();
    //创建websocket连接
    channel = WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket(内容回显)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Send a message'),
              ),
            ),
            StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                //网络不通会走到这
                if (snapshot.hasError) {
                  _text = '网络不通...';
                  print(snapshot.error);
                } else if (snapshot.hasData) {
                  _text = 'echo: ${snapshot.data}';
                }
                print("ss");
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(_text),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(_controller.text);
    } else {
      channel.sink.add('测试数据来了-${DateTime.now()}');
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
