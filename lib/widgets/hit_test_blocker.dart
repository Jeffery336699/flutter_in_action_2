import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class HitTestBlocker extends SingleChildRenderObjectWidget {
  const HitTestBlocker({
    Key? key,
    this.up = true,
    this.down = false,
    this.self = false,
    Widget? child,
  }) : super(key: key, child: child);

  /// Block hit test up.
  ///
  /// if true , `hitTest()` always return false.
  /// 也让兄弟(节点)们也都有机会去hitTest
  final bool up;

  /// Block hit test down. if true, skip `hitTestChildren()`.
  ///
  /// 目前为false:不跳过`hitTestChildren()`,让子类也能正常响应hitTest
  final bool down;

  /// The return value of `hitTestSelf`
  final bool self;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHitTestBlocker(up: up, down: down, self: self);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderHitTestBlocker renderObject) {
    renderObject
      ..up = up
      ..down = down
      ..self = self;
  }
}

class RenderHitTestBlocker extends RenderProxyBox {
  RenderHitTestBlocker({this.up = true, this.down = true, this.self = true});

  bool up;
  bool down;
  bool self;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool hitTestDownResult = false;

    if (!down) {
      hitTestDownResult = hitTestChildren(result, position: position);
    }

    bool pass =
        hitTestSelf(position) || (hitTestDownResult && size.contains(position));

    if (pass) {
      result.add(BoxHitTestEntry(this, position));
    }

    return !up && pass;
  }

  @override
  bool hitTestSelf(Offset position) => self;
}
