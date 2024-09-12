import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

// ignore: slash_for_doc_comments
/**
 * OverflowBox是Flutter中的一个布局小部件（Widget），可允许其子小部件"溢出"父级小部件的约束。在标准的Flutter布局规则中，小部件的大小通常被其父小部件约束，但是OverflowBox提供了一种方式，让子小部件可以在某个方向（水平或垂直）上绘制超出父小部件所提供的空间限制。
    使用场景,OverflowBox的典型使用场景包括：
    当你希望子小部件的大小超过父级小部件提供的空间时。
    实现一些特别的布局效果，例如，一个按钮部分地突出于其容器边界之外。

    注意事项
    请谨慎使用OverflowBox，因为如果不当使用，可能会导致布局问题或者渲染性能下降。特别是在能够通过其他方式实现布局需求的情况下。
    OverflowBox并不改变其子小部件的实际大小，只是改变了子小部件可以绘制的空间。这意味着OverflowBox内的小部件可以绘制到父小部件以外，但它仍然按照原始大小进行布局计算。
    当使用OverflowBox时，要考虑小部件溢出的部分是否会被其他UI元素覆盖，或是否会使用户界面看起来杂乱无章。
 */
class OverflowBoxRoute extends StatefulWidget {
  const OverflowBoxRoute({Key? key}) : super(key: key);

  @override
  State<OverflowBoxRoute> createState() => _OverflowBoxRouteState();
}

class _OverflowBoxRouteState extends State<OverflowBoxRoute> {
  Offset offset = const Offset(0.0, 0.0);
  @override
  Widget build(BuildContext context) {
    return Center(
      // 使用Container作为父小部件以便清楚地看到布局边界
      child: Container(
        width: 200,
        height: 200,
        color: Colors.green,
        child: OverflowBox(
          maxWidth: 300,
          maxHeight: 400,
          // OverflowBox允许其子小部件超出上面约束值
          child: Container(
            width: 250,
            height: 300,
            color: Colors.blue,
          ),
        ).withBorder(color: Colors.red),
      ),
    );
  }
}
