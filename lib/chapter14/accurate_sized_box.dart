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
    //设置当前元素宽高，遵守父组件的约束
    return constraints.constrain(Size(width, height));
  }

  // @override
  // void performResize() {
  //   // default behavior for subclasses that have sizedByParent = true
  //   size = computeDryLayout(constraints);
  //   assert(size.isFinite);
  // }

  @override
  void performLayout() {
    /// performLayout: size.width=98.0 , width=50.0
    /// performLayout: size.height=98.0 , height=50.0
    print('performLayout: size.width=${size.width} , width=$width');
    print('performLayout: size.height=${size.height} , height=$height');
    child!.layout(
      BoxConstraints.tight(
          Size(min(size.width, width), min(size.height, height))),
      // todo parentUseSize为false时，告诉子类父容器(当前)是固定大小，子元素大小改变时不影响父元素;
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
            //实际还是在父容器的约束范围内,只不过满足子类的大小
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
