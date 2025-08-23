import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

import '../widgets/layoutlog.dart';

class FittedBoxRoute extends StatelessWidget {
  const FittedBoxRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(
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
    ),);
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
    // Optimize: 这段讲解得真好，gemini 2.5 pro AI强无敌！！
    // 这段代码通过巧妙地组合 `LayoutBuilder`、`FittedBox` 和 `ConstrainedBox` 来实现子组件自适应父容器宽度的效果。
    // 其核心思想是操纵 Flutter 的布局约束（constraints）。
    //
    // 下面是详细的说明：
    //
    // 1.  **`LayoutBuilder` 的作用**:
    // `LayoutBuilder` 的 `builder` 函数可以获取其父组件传递给它的约束 `constraints`。在这里，`constraints.maxWidth`
    // 代表了 `SingleLineFittedBox` 可以占用的最大宽度（例如，屏幕宽度）。
    //
    // 2.  **`FittedBox` 的布局行为**:
    // `FittedBox` 会在布局其子组件时，先为子组件提供一个无限制的可用空间，让子组件按照自己的期望尺寸进行布局。
    // 然后，`FittedBox` 会将子组件的最终渲染结果进行缩放，以使其适应 `FittedBox` 自身的尺寸。
    //
    // 3.  **`ConstrainedBox` 的关键操作**:
    // 这里的 `ConstrainedBox` 是实现自适应的关键。它对其子组件施加了新的约束：
    // *   `minWidth: constraints.maxWidth`: 它强制子组件的**最小宽度**等于 `LayoutBuilder` 获取到的**最大可用宽度**。
    // *   `maxWidth: double.infinity`: 它允许子组件的宽度可以无限大。
    //
    // **整体流程分析：**
    //
    // 让我们通过两种情况来分析布局过程：
    //
    // *   **情况一：子组件的期望宽度小于父容器宽度** (例如 `wRow(' 800 ')`)
    // 1.  `LayoutBuilder` 获得父容器的宽度，比如是 360。
    // 2.  `FittedBox` 尝试布局其子组件 `ConstrainedBox`。
    // 3.  `ConstrainedBox` 告诉它的子组件（`child`），你的最小宽度必须是 360 (`minWidth: 360`)。
    // 4.  即使 `child` (即 `wRow(' 800 ')`) 本身的期望宽度可能只有 100，但由于 `ConstrainedBox` 的约束，它最终必须以 360 的宽度进行布局。
    // 5.  `ConstrainedBox` 向 `FittedBox` 报告，说它的尺寸是 360。
    // 6.  `FittedBox` 发现其子组件的宽度（360）和自己的可用宽度（360）完全一样，因此不需要进行任何缩放。
    // 7.  **结果**：较短的内容被强制拉伸到父容器的整个宽度，填满了所有空间，实现了“放大”适应的效果。
    //
    // *   **情况二：子组件的期望宽度大于父容器宽度** (例如 `wRow(' 90000000000000000 ')`)
    // 1.  `LayoutBuilder` 获得父容器的宽度，比如是 360。
    // 2.  `FittedBox` 尝试布局其子组件 `ConstrainedBox`。
    // 3.  `ConstrainedBox` 告诉它的子组件（`child`），你的最小宽度是 360，最大宽度是无限 (`minWidth: 360`, `maxWidth: double.infinity`)。
    // 4.  `child` (即超长的 `wRow`) 本身的期望宽度可能需要 1000。这个宽度满足 `ConstrainedBox` 的约束（大于最小宽度360），
    //      所以 `child` 就以 1000 的宽度进行布局。
    // 5.  `ConstrainedBox` 向 `FittedBox` 报告，说它的尺寸是 1000。
    // 6.  `FittedBox` 发现其子组件的宽度（1000）大于自己的可用宽度（360），于是它将子组件按比例缩小 (`360 / 1000 = 0.36` 倍) 以适应自身空间。
    // 7.  **结果**：超长的内容被等比缩小，直到它能完全容纳在父容器的宽度内，避免了溢出，实现了“收缩”适应的效果。
    //
    // **总结**
    //
    // 通过 `ConstrainedBox` 将子组件的最小宽度设置为父容器的可用宽度，确保了当内容本身较少时，其布局空间也能撑满父容器；
    // 而 `FittedBox` 的缩放特性则保证了当内容超出时，会被缩小以防止溢出。二者结合，完美地实现了子组件在单行内自适应填充父容器宽度的效果。
    return LayoutBuilder(
      builder: (_, constraints) {
        print('LayoutBuilder ---> maxWidth: ${constraints.maxWidth}');
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
