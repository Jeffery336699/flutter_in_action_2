import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomRotatedBoxTest extends StatelessWidget {
  const CustomRotatedBoxTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print("tt");

    return Center(
      child: Column(children: <Widget>[
        // 1. 演示一下自定义的旋转组件，是带着内部一起变化，而非paint阶段的假象（涉及到更底层的layer，maxtrx4以及GPU渲染）
        CustomRotatedBox(
          child: Container(
            child: Text(
              "A",
              textScaleFactor: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.pink[200],
              border: Border.all(color: Colors.blue, width: 2),
            ),
          ),
        ),

        // 2. 就算needsCompositing为false，也会把内部跟着一起旋转，因为父子处于同一个图层上
        CustomRotatedBox(
          child: Text(
            "A",
            textScaleFactor: 5,
          ),
        ),

        // 3.1 大前提CustomRotatedBox内部的needsCompositing为false的情况下，简单使用RepaintBoundary包裹，
        // 把父子图层强行分割开来，此时对父容器的旋转不会影响到RepaintBoundary子容器
        // 3.2 如果needsCompositing为true，那么RepaintBoundary包裹也无法阻止父容器的旋转影响到子容器，因为其中发生了父子图层的合成操作，
        // 主要用来针对layer变换操作
        CustomRotatedBox(
          child: RepaintBoundary(
            child: Text(
              "A",
              textScaleFactor: 5,
            ),
          ),
        ),

        ///系统已经帮我们封装好了变化类组件,内部的layer合成都帮我们做好了
        RotatedBox(
          quarterTurns: 1,
          child: RepaintBoundary(
            child: Text(
              "A",
              textScaleFactor: 5,
            ),
          ),
        ),

        ///终极版本,直接使用内置的composite
        CustomRotatedBox2(
          child: RepaintBoundary(
            child: Text(
              "A",
              textScaleFactor: 5,
            ),
          ),
        ),
      ]),
    );

    // return const Center(
    //   child: RepaintBoundary(
    //     child: Text(
    //       "A",
    //       textScaleFactor: 5,
    //     ),
    //   ),
    // );
    //
    // return const Center(
    //   child: const RotatedBox(
    //     quarterTurns: 2,
    //     child: const CustomRotatedBox(
    //       child: Center(
    //         child: Text(
    //           "A",
    //           textScaleFactor: 5,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class CustomRotatedBox extends SingleChildRenderObjectWidget {
  const CustomRotatedBox({Key? key, Widget? child})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CustomRenderRotatedBox();
  }
}

class CustomRenderRotatedBox0 extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  Matrix4? _paintTransform;

  @override
  void performLayout() {
    _paintTransform = null;
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
      //根据子组件大小计算出旋转矩阵
      _paintTransform = Matrix4.identity()
        ..translate(size.width / 2.0, size.height / 2.0)
        ..rotateZ(math.pi / 2)
        ..translate(-child!.size.width / 2.0, -child!.size.height / 2.0);
    } else {
      size = constraints.smallest;
    }
  }

  final LayerHandle<TransformLayer> _transformLayer =
      LayerHandle<TransformLayer>();

  void _paintChild(PaintingContext context, Offset offset) {
    print("paint child");
    context.paintChild(child!, offset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      ///遍历子树查看是否需要合成与把合成缓存起来系统有方法帮我们都做了,就是pipelineOwner.flushCompositingBits()
      ///最后得出的结果就存放在needsCompositing属性中
      _transformLayer.layer = context.pushTransform(
        needsCompositing, // pipelineOwner.flushCompositingBits(); 执行后这个值就能确定
        offset,
        _paintTransform!,
        _paintChild,
        oldLayer: _transformLayer.layer,
      );
    } else {
      _transformLayer.layer = null;
    }
  }

  @override
  void dispose() {
    _transformLayer.layer = null;
    super.dispose();
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (_paintTransform != null) transform.multiply(_paintTransform!);
    super.applyPaintTransform(child, transform);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    assert(_paintTransform != null || debugNeedsLayout || child == null);
    if (child == null || _paintTransform == null) return false;
    return result.addWithPaintTransform(
      transform: _paintTransform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset? position) {
        return child!.hitTest(result, position: position!);
      },
    );
  }
}

class CustomRenderRotatedBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  Matrix4? _paintTransform;

  @override
  void performLayout() {
    _paintTransform = null;
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
      //根据子组件大小计算出旋转矩阵
      _paintTransform = Matrix4.identity()
        ..translate(size.width / 2.0, size.height / 2.0)
        ..rotateZ(math.pi / 2)
        ..translate(-child!.size.width / 2.0, -child!.size.height / 2.0);
    } else {
      size = constraints.smallest;
    }
  }

  final LayerHandle<TransformLayer> _transformLayer =
      LayerHandle<TransformLayer>(TransformLayer());

  void _paintChild(PaintingContext context, Offset offset) {
    print("paint child");
    context.paintChild(child!, offset);
  }

  // 子树中递归查找是否存在绘制边界,以为绘制边界会另起layer，这些都需要合成以便变换类操作可以呈现一致性
  // isRepaintBoundary用于强制创建新的 layer，以实现重绘优化;needsCompositing = true,可能分层
  // needsCompositing 指示一个组件是否需要组合，通常处理变换操作
  // 各司其职吧，个人感觉
  bool needCompositing() {
    bool result = false;
    _visit(RenderObject child) {
      if (child.isRepaintBoundary || child.alwaysNeedsCompositing) {
        result = true;
        return;
      } else {
        child.visitChildren(_visit);
      }
    }

    visitChildren(_visit);
    return result;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.pushTransform(
        needCompositing(),
        offset,
        _paintTransform!,
        _paintChild,
        oldLayer: _transformLayer.layer,
      );
    } else {
      _transformLayer.layer = null;
    }
  }

  @override
  void dispose() {
    _transformLayer.layer = null;
    super.dispose();
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (_paintTransform != null) transform.multiply(_paintTransform!);
    super.applyPaintTransform(child, transform);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    assert(_paintTransform != null || debugNeedsLayout || child == null);
    if (child == null || _paintTransform == null) return false;
    return result.addWithPaintTransform(
      transform: _paintTransform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset? position) {
        return child!.hitTest(result, position: position!);
      },
    );
  }
}

class CustomRotatedBox2 extends SingleChildRenderObjectWidget {
  const CustomRotatedBox2({Key? key, Widget? child})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CustomRenderRotatedBox2();
  }
}

class CustomRenderRotatedBox2 extends CustomRenderRotatedBox0 {
// 针对非绘制边界节点向Layer树中添加新的Layer这种类型,Flutter通过alwaysNeedsCompositing约定来解决问题(底层上报)
// 这种属于动态添加layer的类型，所以需要借助alwaysNeedsCompositing属性来告诉父节点需要合成
// @override
// bool get alwaysNeedsCompositing => true;

  @override
  bool get needsCompositing => true; // 系统也直接支持了这个标志位，相当于一种高效、缓存机制，省的我们每次都去计算一遍
}
