import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'extra_info_constraints.dart';

typedef SliverFlexibleHeaderBuilder = Widget Function(
  BuildContext context,
  double maxExtent,
  ScrollDirection direction,
);

class SliverFlexibleHeader extends StatelessWidget {
  const SliverFlexibleHeader({
    Key? key,
    this.visibleExtent = 0,
    required this.builder,
  }) : super(key: key);

  final SliverFlexibleHeaderBuilder builder;
  final double visibleExtent;

  @override
  Widget build(BuildContext context) {
    return _SliverFlexibleHeader(
      visibleExtent: visibleExtent,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return builder(
            context,
            constraints.maxHeight,
            // 获取滑动方向
            (constraints as ExtraInfoBoxConstraints<ScrollDirection>).extra,
          );
        },
      ),
    );
  }
}

class _SliverFlexibleHeader extends SingleChildRenderObjectWidget {
  const _SliverFlexibleHeader({
    Key? key,
    required Widget child,
    this.visibleExtent = 0,
  }) : super(key: key, child: child);
  final double visibleExtent;
  //貌似是在createRenderObject/updateRenderObject这两个方法里做文章
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _FlexibleHeaderRenderSliver(visibleExtent);
  }

  @override
  void updateRenderObject(
      BuildContext context, _FlexibleHeaderRenderSliver renderObject) {
    renderObject.visibleExtent = visibleExtent;
  }
}

class _FlexibleHeaderRenderSliver extends RenderSliverSingleBoxAdapter {
  _FlexibleHeaderRenderSliver(double visibleExtent)
      : _visibleExtent = visibleExtent;
  double _lastOverScroll = 0;
  double _lastScrollOffset = 0;
  double _visibleExtent = 0;
  ScrollDirection _direction = ScrollDirection.idle;

  // 该变量用来确保Sliver完全离开屏幕时会通知child且只通知一次.
  bool _reported = false;

  // 是否需要修正scrollOffset. _visibleExtent 值更新后，
  // 为了防止突然的跳动，要先修正 scrollOffset。
  double? _scrollOffsetCorrection;

  set visibleExtent(double value) {
    // 可视长度发生变化，更新状态并重新布局
    if (_visibleExtent != value) {
      _lastOverScroll = 0;
      _reported = false;
      // 计算修正值
      _scrollOffsetCorrection = value - _visibleExtent;
      _visibleExtent = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    // _visibleExtent 值更新后，为了防止突然的跳动，先修正 scrollOffset
    if (_scrollOffsetCorrection != null) {
      geometry = SliverGeometry(
        //修正
        scrollOffsetCorrection: _scrollOffsetCorrection,
      );
      _scrollOffsetCorrection = null;
      return;
    }

    if (child == null) {
      geometry = SliverGeometry(scrollExtent: _visibleExtent);
      return;
    }

    //当已经完全滑出屏幕时
    if (constraints.scrollOffset > _visibleExtent) {
      geometry = SliverGeometry(scrollExtent: _visibleExtent);
      // 通知 child 重新布局，注意，通知一次即可，如果不通知，滑出屏幕后，child 在最后
      // 一次构建时拿到的可用高度可能不为 0。因为使用者在构建子节点的时候，可能会依赖
      // "当前的可用高度是否为0" 来做一些特殊处理，比如记录是否子节点已经离开了屏幕，
      // 因此，我们需要在离开屏幕时确保LayoutBuilder的builder会被调用一次（构建子组件）。
      if (!_reported) {
        _reported = true;
        child!.layout(
          ExtraInfoBoxConstraints(
            _direction, //传递滑动方向
            //     `constraints.asBoxConstraints(maxExtent: 0)` 这行代码的作用是创建一个 `BoxConstraints` 对象，并将其 `maxHeight`（在垂直滚动视图中）或 `maxWidth`（在水平滚动视图中）设置为 0。
            //
            //     ### 理解
            //     在 `_FlexibleHeaderRenderSliver` 的 `performLayout` 方法中，这行代码出现在 `constraints.scrollOffset > _visibleExtent` 的判断条件内。这个条件意味着该 Sliver 组件已经被完全滚动到屏幕可视区域之外。
            //
            //     此时，调用 `child!.layout(...)` 并传入一个最大高度为 0 的约束，是为了通知子组件（通常是一个 `LayoutBuilder`）它的可用显示空间已经变为 0。
            //
            //     ### 实战用途
            //     这种做法在自定义 Sliver 组件时很常见，主要目的如下：
            //
            //     1.  **状态通知**：让子组件知道它已经不可见了。开发者可以在 `LayoutBuilder` 的 `builder` 回调中检查 `constraints.maxHeight` 是否为 0。如果为 0，就可以执行一些特定的逻辑，例如：
            //        *   停止动画。
            //        *   释放资源。
            //        *   更新状态（例如，一个 `ValueNotifier`），通知应用的其他部分该组件已滚出屏幕。
            //
            //     2.  **性能优化**：当组件不可见时，通过给它一个大小为 0 的约束，可以避免不必要的绘制和布局计算，从而提升性能。
            //
            //     3.  **确保一致性**：保证当 Sliver 滚出屏幕时，其子组件最后一次布局得到的尺寸是 0。这可以防止因布局状态不一致而导致的潜在问题。
            //
            //     在您的代码中，注释已经很好地解释了这一点：
            //         > ...我们需要在离开屏幕时确保LayoutBuilder的builder会被调用一次（构建子组件）。
            //
            //     通过传递 `maxExtent: 0`，强制子 `LayoutBuilder` 使用高度为 0 的约束来重建其子项，从而确保了状态的正确同步。
            constraints.asBoxConstraints(maxExtent: 0),
          ),
          //我们不会使用子节点的 Size, 关于此参数更详细的内容见本书后面关于layout原理的介绍
          parentUsesSize: false,
        );
      }
      return;
    }

    //子组件回到了屏幕中，重置通知状态
    _reported = false;
    /**
     *  todo: 讲解得非常好，还得是Gemini 2.5 pro(github copilot中得最强大的版本)才能写出这种解释
     *  好的，我们来逐行分析这段代码，以理解它是如何确定滚动方向的。

        这段代码的核心目标是**精确地判断出列表内容当前的滚动方向（向上还是向下）**，而不仅仅是用户手指滑动的方向。这在处理像“下拉刷新”后列表自动弹回这类非用户直接操作的滚动时尤其重要。

        ### 代码分解

        1.  **`double overScroll = constraints.overlap < 0 ? constraints.overlap.abs() : 0;`**
     *   `constraints.overlap`：表示当前 Sliver 与上一个 Sliver 的重叠量。当列表滚动到顶部，用户继续向下拉时，`overlap` 会变成一个负数。
     *   这行代码的作用是：如果用户正在下拉超出顶部边界（`overlap < 0`），就将超出的距离（绝对值）赋值给 `overScroll`。否则，`overScroll` 为 0。`overScroll` 基本上就是“下拉距离”。

        2.  **`var scrollOffset = constraints.scrollOffset;`**
     *   `constraints.scrollOffset`：表示当前 Sliver 已经被向上卷去（滚出屏幕顶部）的距离。
     *   这里将它存入一个局部变量 `scrollOffset` 以便后续计算。

        3.  **`var distance = overScroll > 0 ? overScroll - _lastOverScroll : _lastScrollOffset - scrollOffset;`**
     *   这是判断滚动方向和距离的关键。它分为两种情况：
     *   **情况一：正在下拉超出边界 (`overScroll > 0`)**
     *   此时，通过 `overScroll - _lastOverScroll` 计算距离。`_lastOverScroll` 是上一次布局时的下拉距离。
     *   如果 `distance > 0`，意味着本次的下拉距离比上次大，说明用户还在继续往下拉。
     *   如果 `distance < 0`，意味着本次的下拉距离比上次小，说明用户松手了，列表正在自动弹回。
     *   **情况二：在正常范围内滚动 (`overScroll == 0`)**
     *   此时，通过 `_lastScrollOffset - scrollOffset` 计算距离。`_lastScrollOffset` 是上一次布局时的滚动偏移量。
     *   如果 `distance > 0`，意味着上次的偏移量比本次大（`scrollOffset` 变小了），说明列表正在向**下**滚动（内容在往下走，显示之前被卷上去的内容）。
     *   如果 `distance < 0`，意味着上次的偏移量比本次小（`scrollOffset` 变大了），说明列表正在向**上**滚动（内容在往上走，被卷出屏幕）。

        4.  **`_lastOverScroll = overScroll;`** 和 **`_lastScrollOffset = scrollOffset;`**
     *   在计算完 `distance` 后，更新 `_lastOverScroll` 和 `_lastScrollOffset` 的值，将当前帧的滚动状态保存起来，以便在下一帧布局时进行比较。

        ### 总结

        这段代码通过比较**当前帧**和**上一帧**的滚动位置（`scrollOffset`）或下拉距离（`overScroll`），来计算出一个 `distance` 值。
        这个 `distance` 的正负号就可靠地代表了列表内容真实的滚动方向，解决了 `constraints.userScrollDirection` 无法覆盖所有场景（如自动弹回）的问题。
     */
    // 下拉过程中overlap会一直变化.
    double overScroll = constraints.overlap < 0 ? constraints.overlap.abs() : 0;
    var scrollOffset = constraints.scrollOffset;
    _direction = ScrollDirection.idle;

    // 根据前后的overScroll值之差确定列表滑动方向。注意，不能直接使用 constraints.userScrollDirection，
    // 这是因为该参数只表示用户滑动操作的方向。比如当我们下拉超出边界时，然后松手，此时列表会弹回，即列表滚动
    // 方向是向上，而此时用户操作已经结束，ScrollDirection 的方向是上一次的用户滑动方向(向下)，这时便有问题。
    var distance = overScroll > 0
        ? overScroll - _lastOverScroll
        : _lastScrollOffset - scrollOffset;
    _lastOverScroll = overScroll;
    _lastScrollOffset = scrollOffset;

    if (constraints.userScrollDirection == ScrollDirection.idle) {
      _direction = ScrollDirection.idle;
      _lastOverScroll = 0;
    } else if (distance > 0) {
      _direction = ScrollDirection.forward;
    } else if (distance < 0) {
      _direction = ScrollDirection.reverse;
    }

    // 在Viewport中顶部的可视空间为该 Sliver 可绘制的最大区域。
    // 1. 如果Sliver已经滑出可视区域则 constraints.scrollOffset 会大于 _visibleExtent，
    //    这种情况我们在一开始就判断过了。
    // 2. 如果我们下拉超出了边界，此时 overScroll>0，scrollOffset 值为0，所以最终的绘制区域为
    //    _visibleExtent + overScroll.
    double paintExtent = _visibleExtent + overScroll - constraints.scrollOffset;
    // 绘制高度不超过最大可绘制空间
    paintExtent = min(paintExtent, constraints.remainingPaintExtent);

    //对子组件进行布局，子组件通过 LayoutBuilder可以拿到这里我们传递的约束对象（ExtraInfoBoxConstraints）
    child!.layout(
      ExtraInfoBoxConstraints(
        _direction, //传递滑动方向
        constraints.asBoxConstraints(maxExtent: paintExtent),
      ),
      parentUsesSize: false,
    );

    //最大为_visibleExtent，最小为 0
    double layoutExtent = min(_visibleExtent, paintExtent);

    //设置geometry，Viewport 在布局时会用到
    geometry = SliverGeometry(
      scrollExtent: _visibleExtent,
      paintOrigin: -overScroll,
      paintExtent: paintExtent,
      maxPaintExtent: paintExtent,
      layoutExtent: layoutExtent,
    );
  }
}
