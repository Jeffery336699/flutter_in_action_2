import 'package:flutter/material.dart';

import 'renderobject_animation_mixin.dart';

class DoneWidget extends LeafRenderObjectWidget {
  const DoneWidget(
      {Key? key,
      this.strokeWidth = 2.0,
      this.color = Colors.green,
      this.outline = false,
      this.show = true})
      : super(key: key);

  //线条宽度
  final double strokeWidth;
  //轮廓颜色或填充色
  final Color color;
  //如果为true，则没有填充色，color代表轮廓的颜色；如果为false，则color为填充色
  final bool outline;
  final bool show;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDoneObject(strokeWidth, color, outline, show)
      ..animationStatus = AnimationStatus.forward; // 创建时执行正向动画
  }

  @override
  void updateRenderObject(context, RenderDoneObject renderObject) {
    print('renderObject.show=${renderObject.show} , show=$show');

    ///todo renderObject:表示的是之前的,动画的启动逻辑就在状态的变更中,具体RenderObjectAnimationMixin中会把其标记为需要绘制
    if (renderObject.show != show) {
      renderObject.animationStatus =
          show ? AnimationStatus.forward : AnimationStatus.reverse;
    }

    ///记得把旧状态更新
    renderObject
      ..strokeWidth = strokeWidth
      ..outline = outline
      ..color = color
      ..show = show;
  }
}

class RenderDoneObject extends RenderBox with RenderObjectAnimationMixin {
  double strokeWidth;
  Color color;
  bool outline;
  bool show;

  ValueChanged<bool>? onChanged;

  RenderDoneObject(
    this.strokeWidth,
    this.color,
    this.outline,
    this.show,
  );

  // 动画执行时间为 300ms
  @override
  Duration get duration => const Duration(milliseconds: 300);

  @override
  void doPaint(PaintingContext context, Offset offset) {
    // 可以对动画运用曲线
    Curve curve = Curves.easeIn;
    final _progress = curve.transform(progress);

    Rect rect = offset & size;
    final paint = Paint()
      ..isAntiAlias = true
      ..style = outline ? PaintingStyle.stroke : PaintingStyle.fill //填充
      ..color = color;

    if (outline) {
      paint.strokeWidth = strokeWidth;
      rect = rect.deflate(strokeWidth / 2);
    }

    // 画背景圆
    context.canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);

    paint
      ..style = PaintingStyle.stroke
      ..color = outline ? color : Colors.white
      ..strokeWidth = strokeWidth;

    final path = Path();

    Offset firstOffset =
        Offset(rect.left + rect.width / 6, rect.top + rect.height / 2.1);

    final secondOffset = Offset(
      rect.left + rect.width / 2.5,
      rect.bottom - rect.height / 3.3,
    );

    path.moveTo(firstOffset.dx, firstOffset.dy);

    const adjustProgress = .6;
    //画 "勾"
    if (_progress < adjustProgress) {
      ///第一个点到第二个点的连线做动画(第二个点不停的变)
      Offset _secondOffset = Offset.lerp(
        firstOffset,
        secondOffset,
        _progress / adjustProgress,
      )!;
      path.lineTo(_secondOffset.dx, _secondOffset.dy);
    } else {
      //链接第二个点和第三个点
      path.lineTo(secondOffset.dx, secondOffset.dy);

      ///第三个点位置随着动画变，做动画
      final lastOffset = Offset(
        rect.right - rect.width / 5,
        rect.top + rect.height / 3.5,
      );
      Offset _lastOffset = Offset.lerp(
        secondOffset,
        lastOffset,
        (progress - adjustProgress) / (1 - adjustProgress),
      )!;
      path.lineTo(_lastOffset.dx, _lastOffset.dy);
    }

    ///应用drawPath,path路径信息
    context.canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  void performLayout() {
    // 如果父组件指定了固定宽高，则使用父组件指定的，否则宽高默认置为 25
    size = constraints.constrain(
      constraints.isTight ? Size.infinite : const Size(25, 25),
    );
  }
}
