import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

import '../widgets/layoutlog.dart';

class FittedBoxRoute extends StatelessWidget {
  const FittedBoxRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        wContainer(BoxFit.none, clip: false, opacity: 0.35),
        const Text('Wendux-(不裁剪)'),
        wContainer(BoxFit.none),
        const Text('Wendux-(裁剪)且不缩放'),
        wContainer(BoxFit.contain),
        const Text('Wendux-(裁剪)且等比缩放至包含在父容器中'),
        ...wRows(),
      ],
    );
  }

  ///裁剪的真正含义就是对(子组件)绘制阶段超出父容器范围的区域的处理方式,就像裁剪布料一样去掉不要咯
  Widget wContainer(BoxFit boxFit, {bool clip = true, double opacity = 1}) {
    var widget = Container(
      width: 50,
      height: 50,
      color: Colors.red,
      child: FittedBox(
        fit: boxFit,
        child: Container(width: 60, height: 70, color: Colors.blue),
      ).opacity(opacity),
    );
    return clip
        ? ClipRect(
            child: widget,
          )
        : widget;
  }

  List<Widget> wRows() {
    return [
      wRow(' 90000000000000000 '),

      ///类似于图片的大小等比缩放至父容器的填充,只不过这里针对的是文本缩放至父容器的填充(动态变化的是字体大小)
      SingleLineFittedBox(child: wRow(' 90000000000000000 ')),
      const Divider(),
      wRow(' 800 '),
      SingleLineFittedBox(child: wRow(' 800 ')),
      LayoutLogPrint(tag: 1, child: wRow(' 800 ')),
      // SingleLineFittedBox(child: LayoutLogPrint(tag: 2, child: wRow(' 800 '))),
    ]
        .map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: e,
            ))
        .toList();
  }

  Widget wRow(String text) {
    Widget child = Text(
      text,
      style: const TextStyle(fontSize: 20),
    );
    child = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [child, child, child],
    );
    return child;
  }

  Widget wRow1(String text) {
    Widget child = Text(text);
    child = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [child, child, child],
    );
    return LayoutBuilder(
      builder: (_, constraints) {
        print(constraints);
        // return FittedBox(
        //   child: child,
        // );
        return FittedBox(
          child: ConstrainedBox(
            constraints: constraints.copyWith(
              minWidth: constraints.maxWidth,
              maxWidth: double.infinity,
            ),
            child: child,
          ),
        );
      },
    ); //return FittedBox(child: row);
  }
}

/// 针对长于目标的(eg 屏幕)的就是收缩,对于短于目标的(eg 屏幕)的就是放大填充
class SingleLineFittedBox extends StatelessWidget {
  const SingleLineFittedBox({Key? key, this.child}) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        print('LayoutBuilder ---> ${constraints.maxWidth}');
        return FittedBox(
          child: ConstrainedBox(
            constraints: constraints.copyWith(
              minWidth: constraints.maxWidth,
              maxWidth: double.infinity,
              //maxWidth: constraints.maxWidth
            ),
            child: child,
          ),
        );
      },
    );
  }
}
