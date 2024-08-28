import 'dart:math' as math;

import 'package:flutter/material.dart';

class TransformRoute extends StatelessWidget {
  const TransformRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var children = [
      Container(
        color: Colors.black,

        ///Transform针对的都是其包裹的子组件进行变换,并且作用于绘制阶段,即它原本的布局位置并没有改变哟!
        child: Transform(
          alignment: Alignment.topRight, //相对于坐标系原点的对齐方式
          transform: Matrix4.skewY(0.3), //沿Y轴倾斜0.3弧度
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.deepOrange,
            child: const Text('Apartment for rent!'),
          ),
        ),
      ),
      DecoratedBox(
        decoration: const BoxDecoration(color: Colors.red),
        //默认原点为左上角，左移20像素，向上平移5像素
        child: Transform.translate(
          offset: const Offset(-20.0, -5.0),
          child: const Text("Hello world"),
        ),
      ),
      DecoratedBox(
        decoration: const BoxDecoration(color: Colors.red),
        child: Transform.rotate(
          //旋转90度
          angle: math.pi / 2,
          child: const Text("Hello world"),
        ),
      ),
      DecoratedBox(
        decoration: const BoxDecoration(color: Colors.red),
        child: Transform.scale(
          scale: 1.5, //放大到1.5倍
          child: const Text("Hello world"),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ///可以看出Transform变换仅仅是一种视觉上的变化(绘制阶段),实际位置并没有发生变化(布局阶段)
          DecoratedBox(
            decoration: const BoxDecoration(color: Colors.red),
            child: Transform.scale(
              scale: 1.5,
              child: const Text("Hello world"),
            ),
          ),
          const Text(
            "你好",
            style: TextStyle(color: Colors.green, fontSize: 18.0),
          )
        ],
      ),
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(color: Colors.red),

            ///想要真正的布局也发生变化,可以将Transform.rotate换成RotatedBox
            child: RotatedBox(
              quarterTurns: 1, //旋转90度(1/4圈)
              child: Text("Hello world"),
            ),
          ),
          Text(
            "你好",
            style: TextStyle(color: Colors.green, fontSize: 18.0),
          )
        ],
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children
          .map((e) => Padding(
                padding: const EdgeInsets.only(top: 30),
                child: e,
              ))
          .toList(),
    );
  }
}
