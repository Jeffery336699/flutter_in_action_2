import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class CustomRotatedBoxTest extends StatelessWidget {
  const CustomRotatedBoxTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print("tt");

    return const Center(
      child: Column(children: <Widget>[
        CustomRotatedBox(
          child: Text(
            "A",
            textScaleFactor: 5,
          ),
        ),
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

  //子树中递归查找是否存在绘制边界
  needCompositing() {
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
  @override
  needCompositing() => true;
  //针对非绘制边界节点向Layer树中添加新的Layer这种类型,Flutter通过alwaysNeedsCompositing约定来解决问题(底层上报)
  // @override
  // bool get alwaysNeedsCompositing => true;
}
