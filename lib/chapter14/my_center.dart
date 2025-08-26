import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_in_action_2/ext.dart';

class CustomCenter1 extends SingleChildRenderObjectWidget {
  const CustomCenter1({Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomCenter1();
  }
}

//RenderShiftedBox a;
class RenderCustomCenter1 extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  @override
  void performLayout() {
    // 1. 子组件进行layout，传递你根据父容器的约束来取决于你希望如何约束子组件，随后获取它的size
    child!.layout(
      constraints.loosen(),
      parentUsesSize:
          true, // 因为我们接下来要使用child的size,所以不能为false
    );
    /**
     *  constraints.maxWidth == double.infinity:false,
        constraints.maxHeight == double.infinity:true
        1. 因为此时的单组件容器的父容器是Column，Column的宽度最多是屏幕宽度，所以maxWidth不是无穷大
        2. 因为Column是垂直方向的，所以高度是无穷大
     */
    print(
        'constraints.maxWidth == double.infinity:${constraints.maxWidth == double.infinity},\n'
        'constraints.maxHeight == double.infinity:${constraints.maxHeight == double.infinity}');
    // 2. 子组件的size宽高确定好了之后，确定自身(容器)的宽高，同样是结合上层容器给自己的约束和子组件来共同确定
    // 这段代码的目的是根据父组件传递的约束（`constraints`）来确定当前自定义组件的尺寸（`size`），其行为模仿了 Flutter 内置的 `Center` 组件。
    //
    // 代码的核心设计思想如下：
    //
    // 1.  **尽可能地撑满**：`Center` 组件的行为是在其父组件允许的范围内，尽可能地占据更多空间。
    // 2.  **处理有界和无界约束**：
    // *   当父组件在某个维度（宽或高）上提供了**有界**的约束（例如，`constraints.maxWidth` 不是 `double.infinity`）时，
    //     `Center` 组件应该扩展到该维度的最大值。通过将 `double.infinity` 传递给 `constraints.constrain()`，
    //     最终的尺寸会被限制为父组件允许的最大尺寸，即 `constraints.maxWidth` 或 `constraints.maxHeight`。
    // *   当父组件在某个维度上提供了**无界**的约束（例如，`constraints.maxWidth` 是 `double.infinity`，
    //     常见于可滚动列表的主轴方向）时，如果 `Center` 组件也尝试无限扩展，将会导致布局错误。因此，在这种情况下，
    //     它应该收缩自己的尺寸以匹配其子组件的尺寸（`child!.size.width` 或 `child!.size.height`）。
    //
    // 简而言之，这段代码实现了 `Center` 组件的关键布局逻辑：在有界约束下撑满，在无界约束下包裹内容。
    size = constraints.constrain(Size(
      constraints.maxWidth == double.infinity
          ? child!.size.width
          : double.infinity,
      constraints.maxHeight == double.infinity
          ? child!.size.height
          : double.infinity,
    ));
    // 3. 设置子组件在自身容器中的额外信息，比如偏移量，这里是演示居中显示
    BoxParentData parentData =
        child!.parentData as BoxParentData;
    // 居中显示
    ///size=Size(328.0, 50.0)  ,  child!.size=Size(50.0, 50.0)
    print('size=$size  ,  child!.size=${child!.size}');
    // Optimize: 子类上报给父容器它在父容器中的偏移量
    parentData.offset =
        ((size - child!.size) as Offset) / 2;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result,
      {required Offset position}) {
    final BoxParentData childParentData =
        child!.parentData! as BoxParentData;
    /**
     * hitTestChildren --> position=Offset(103.4, 26.8) , childParentData.offset=Offset(162.7, 0.0)
     * hitTestChildren --> position=Offset(32.9, 12.3) , childParentData.offset=Offset(162.7, 0.0)
     * -------------------------------------------------------------------------------------------
     * position是点击(指点到容器上)的位置，childParentData.offset是子组件在父容器中的偏移（本实例没有变）
     */
    print(
        'hitTestChildren --> position=$position , childParentData.offset=${childParentData.offset}');
    /**
     * addWithPaintOffset方法的作用是：
     * 1. 调整触摸坐标系统：将父容器的触摸位置坐标转换到子组件的坐标空间。
     * 2. 进行子组件命中测试：调用子组件的hitTest方法检查是否有命中。
     */
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest:
          (BoxHitTestResult result, Offset? transformed) {
        return child!
            .hitTest(result, position: transformed!);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    BoxParentData parentData =
        child!.parentData as BoxParentData;

    /// 绘制子组件，偏移量为offset（自身偏移） + parentData.offset（子组件在我容器中的偏移）
    print(
        'paint --> offset=$offset , parentData.offset=${parentData.offset}');
    context.paintChild(child!, offset + parentData.offset);
  }
}

class CustomCenter2 extends SingleChildRenderObjectWidget {
  const CustomCenter2({Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomCenter2();
  }
}

///RenderObject采用子类RenderShiftedBox,他帮我们实现了layout之外的一些功能
class RenderCustomCenter2 extends RenderShiftedBox {
  RenderCustomCenter2({RenderBox? child}) : super(child);

  @override
  void performLayout() {
    //子组件进行layout，随后获取它的size
    child!.layout(
      constraints.loosen(),
      parentUsesSize:
          true, // 因为我们接下来要使用child的size,所以不能为false
    );
    // 设置自身的大小，防止size宽高无穷大
    size = constraints.constrain(Size(
      constraints.maxWidth == double.infinity
          ? child!.size.width
          : double.infinity,
      constraints.maxHeight == double.infinity
          ? child!.size.height
          : double.infinity,
    ));

    BoxParentData parentData =
        child!.parentData as BoxParentData;
    // 居中显示
    parentData.offset =
        ((size - child!.size) as Offset) / 2;
  }
}

/// 思考题：能否使用CustomSingleChildLayout 来实现Center呢

class MyCenterRoute extends StatefulWidget {
  const MyCenterRoute({Key? key}) : super(key: key);

  @override
  State<MyCenterRoute> createState() =>
      _MyCenterRouteState();
}

class _MyCenterRouteState extends State<MyCenterRoute> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomCenter1(
          child: GestureDetector(
            onTap: () {
              setState(() {
                print("tap");
              });
            },
            child: Container(
                width: 50,
                height: 50,
                color: Colors.pinkAccent),
          ).withBorder(color: Colors.black, width: 3),
        ).withBorder(),
        const SizedBox(
          height: 20,
        ),
        CustomCenter2(
          child: GestureDetector(
            onTap: () {
              setState(() {
                print("tap");
              });
            },
            child: Container(
                width: 50, height: 50, color: Colors.green),
          ).withBorder(color: Colors.black, width: 3),
        ).withBorder(),
      ],
    );
  }
}
