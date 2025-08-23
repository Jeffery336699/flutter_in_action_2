import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

class TextRoute extends StatefulWidget {
  const TextRoute({Key? key}) : super(key: key);

  @override
  _TextRouteState createState() => _TextRouteState();
}

class _TextRouteState extends State<TextRoute> {
  late GestureRecognizer _tapRecognizer;

  @override
  void initState() {
    _tapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        print("Link clicked");
      };
    super.initState();
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: const Text(
                "Hello world",
                textAlign: TextAlign.start,
              ).withBorder())
            ],
          ),
          Text(
            "Hello world! I'm Jack. " * 4,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Text(
            "Hello world",
            textScaler: TextScaler.linear(1.5),
          ),
          Text(
            "Hello world " * 6, //字符串重复六次
            textAlign: TextAlign.center,
          ),
          Text(
            "Hello world",
            style: TextStyle(
                color: Colors.blue,
                fontSize: 18.0,
                height: 1.2,
                fontFamily: "Courier",
                background: Paint()..color = Colors.yellow,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dashed),
          ),
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: "Home: "),
              TextSpan(
                  text: "https://flutterchina.club",
                  style: const TextStyle(color: Colors.blue),
                  recognizer: _tapRecognizer),
            ]),
          ),


          DefaultTextStyle(
            /// 1.设置文本默认样式
            style: const TextStyle(
              color: Colors.red,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.left,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("hello world",textAlign: TextAlign.center).withBorder(),
                /// 这里DefaultTextStyle中的textAlign没起到作用还是居中显示,
                /// 原因是Text组件本身占用的宽度就是它自身的长度，没有多余的空间给你来摆放textAlign属性
                /// 要想改变可以像第一个组件Row+Expanded的方式,可用空间撑满再在可用空间中进行子组件的摆放
                Row(
                  children: const [
                    Expanded(child: Text("I am Jack",style: TextStyle(),textAlign: TextAlign.center,)),
                  ],
                ),
                Text(
                  "I am Jack",
                  style: TextStyle(
                    /// ①inherit: true继承的话,只对自身修改的进行变化,其他还是默认(同android设置主题类似)
                    /// ②inherit: false不继承的话,完全与DefaultTextStyle默认样式无关
                    inherit: false,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "I am Jack",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ).withBorder(color: Colors.yellow),
    );
  }
}
