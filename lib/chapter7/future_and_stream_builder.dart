import 'dart:async';

import 'package:flutter/material.dart';

class FutureAndStreamBuilderRoute extends StatefulWidget {
  const FutureAndStreamBuilderRoute({Key? key}) : super(key: key);

  @override
  _FutureAndStreamBuilderRouteState createState() =>
      _FutureAndStreamBuilderRouteState();
}

class _FutureAndStreamBuilderRouteState
    extends State<FutureAndStreamBuilderRoute> {
  late Future<String> _future;

  @override
  void initState() {
    _future = mockNetworkData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Center(
    //   child: FutureBuilder<String>(
    //     future: _future,
    //     builder: (BuildContext context, AsyncSnapshot snapshot) {
    //       print(snapshot.connectionState);
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         if (snapshot.hasError) {
    //           return Text("Error: ${snapshot.error}");
    //         } else {
    //           return Text("Contents: ${snapshot.data}");
    //         }
    //       } else {
    //         //
    //         return const CircularProgressIndicator();
    //       }
    //     },
    //   ),
    // );

    return Center(
      child: StreamBuilder<int>(
        stream: counter(), //
        //initialData: ,// a Stream<int> or null
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          print(snapshot.connectionState);
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Text('没有Stream');
            case ConnectionState.waiting:
              return const Text('等待数据...');
            case ConnectionState.active: //stream所特有的
              return Text('active: ${snapshot.data}');
            case ConnectionState.done:
              return const Text('Stream已关闭');
          }
        },
      ),
    );
  }

  Future<String> mockNetworkData() async {
    return Future.delayed(const Duration(seconds: 3), () => "我是从互联网上获取的数据");
  }

  Stream<int> counter() {
    return Stream.periodic(const Duration(seconds: 1), (i) {
      return i;
    }).take(10);
  }
}
