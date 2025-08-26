import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_in_action_2/ext.dart';

class AccurateSizedBox extends SingleChildRenderObjectWidget {
  const AccurateSizedBox({
    Key? key,
    this.width = 0,
    this.height = 0,
    required Widget child,
  }) : super(key: key, child: child);

  final double width;
  final double height;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAccurateSizedBox(width, height);
  }

  @override
  void updateRenderObject(context, RenderAccurateSizedBox renderObject) {
    renderObject
      ..width = width
      ..height = height;
  }
}

class RenderAccurateSizedBox extends RenderProxyBoxWithHitTestBehavior {
  RenderAccurateSizedBox(this.width, this.height);

  double width;
  double height;

  // 当前组件的大小只取决于父组件传递的约束
  @override
  bool get sizedByParent => true;

  // performResize 中会调用
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    // 0. 98.0 , 98.0
    print('0. ${constraints.minWidth} , ${constraints.maxWidth}');
    print('1. computeDryLayout: constraints=$constraints , width=$width');
    //设置当前元素宽高，遵守父组件的约束
     var size = constraints.constrain(Size(width, height));
    // 1.1 computeDryLayout: size=Size(98.0, 98.0)
    print('1.1 computeDryLayout: size=$size');
    return size;
  }

  // performResize和 Android 中的onMeasure之间确实存在一定相似性，特别是在它们负责计算组件尺寸这一点上，
  // 但在具体实现和使用场景上也有显著区别。Flutter 的布局系统更强调使用约束传递和父子关系的配合，
  // 直接涉及performResize的场景相对较少，而 Android 的onMeasure则是必不可少的核心方法。
  // @override
  // void performResize() {
  //   // default behavior for subclasses that have sizedByParent = true
  //   size = computeDryLayout(constraints);
  //   assert(size.isFinite);
  // }

  @override
  Future<void> performLayout() async {
    /// performLayout: size.width=98.0 , width=50.0
    /// performLayout: size.height=98.0 , height=50.0
    print('2. pL父容器约束width=${size.width} , 子child请求width=$width');
    print('2. pL父容器约束height=${size.height} , 子child请求height=$height');
    child!.layout(
      BoxConstraints.tight(
          Size(min(size.width, width), min(size.height, height))),
      // todo parentUseSize为false时，告诉子组件布局时，本容器(当前)是固定大小，子元素大小改变时不影响父元素;
      // todo 即 子组件的布局边界会是它自身，子组件布局发生变化后不会影响当前组件
      parentUsesSize: false,
    );
  }
}

class AccurateSizedBoxRoute extends StatelessWidget {
  const AccurateSizedBoxRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: () => print("tap"),
      child: Container(width: 300, height: 300, color: Colors.red),
    );
    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints.tight(const Size(100, 100)),
          child: SizedBox(
            width: 50,
            height: 50,
            child: child,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(const Size(100, 100)),
            // 这个width、height给child设计的，大前提还是在上层约束下
            child: AccurateSizedBox(
              width: 50,
              height: 50,
              child: child,
            ).withBorder(),
          ),
        ),
      ],
    );
  }
}
