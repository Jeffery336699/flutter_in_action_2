import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

class StackRoute extends StatelessWidget {
  const StackRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          Container(
            child: const Text(
              "Hello world",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.red,
          ),
          // 这个 `Positioned` Widget 只设置了 `left` 属性，没有设置 `top` 或 `bottom` 这样的垂直方向的属性。
          // 对于这种部分定位（partially positioned）的子组件，`Stack` 会使用它的 `alignment` 属性来决定其在未指定方向上的位置。
          //
          // 在这个例子中，`Stack` 的 `alignment` 被设置为 `Alignment.center`（见第 12 行）。
          // 由于 `Positioned` Widget 的垂直位置没有被指定，它会根据 `Stack` 的 `alignment` 属性在垂直方向上居中对齐。
          const Positioned(
            left: 18.0,
            child: Text("I am Jack"),
          ),
          const Positioned(
            top: 18.0,
            child: Text("Your friend"),
          )
        ],
      ).withBorder(),
    );
  }
}
