import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'extra_info_constraints.dart';

typedef SliverPersistentHeaderToBoxBuilder = Widget
    Function(
  BuildContext context,
  double maxExtent,
  bool fixed,
);

class SliverPersistentHeaderToBox extends StatelessWidget {
  SliverPersistentHeaderToBox({
    Key? key,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        super(key: key);

  const SliverPersistentHeaderToBox.builder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final SliverPersistentHeaderToBoxBuilder builder;

  @override
  Widget build(BuildContext context) {
    return _SliverPersistentHeaderToBox(
      child: LayoutBuilder(
        builder: (BuildContext context,
            BoxConstraints constraints) {
          return builder(
            context,
            constraints.maxHeight,
            //父类能给到该组件的最大高度,从LayoutBuilder就能看出父类对子类的约束
            (constraints as ExtraInfoBoxConstraints<bool>)
                .extra,
          );
        },
      ),
    );
  }
}

class _SliverPersistentHeaderToBox
    extends SingleChildRenderObjectWidget {
  const _SliverPersistentHeaderToBox({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSliverPersistentHeaderToBox();
  }
}

class _RenderSliverPersistentHeaderToBox
    extends RenderSliverSingleBoxAdapter {
  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    /*  `parentUsesSize: true` 是 Flutter `RenderObject` 中 `layout` 方法的一个重要参数。

    ### `parentUsesSize` 的含义

    当一个父级 `RenderObject` 在布局其子级时，如果将 `parentUsesSize` 设置为 `true`，则表示**父级的尺寸或布局决策依赖于子级的尺寸**。

    这会告诉 Flutter 框架：
    1.  在子级布局完成后，父级需要读取子级的 `size` 属性。
    2.  如果子级被标记为需要重新布局（`markNeedsLayout`），那么父级也必须被标记为需要重新布局，因为子级的尺寸变化会影响父级。

    如果设置为 `false`（默认值），则表示父级的布局不依赖于子级的尺寸。这是一种性能优化，因为当子级尺寸变化时，框架不必重新布局父级。

    ### 一般使用场景

    当父组件需要根据子组件的大小来决定自身大小时，就需要将 `parentUsesSize` 设置为 `true`。

    **常见场景举例：**

    1.  **包裹内容的容器**：一个没有明确设置宽高的 `Container` 或 `Center` 组件，它的大小需要根据其 `child` 的大小来确定。
    例如，`Center` 组件需要知道子组件的大小才能将其居中。

    2.  **自定义布局**：在实现自定义的 `RenderObject` 时，如果你的 `performLayout` 方法中需要读取 `child.size` 来计算
    自身的 `size` 或其他布局属性（比如在你的代码中），就必须在调用 `child.layout` 时传递 `parentUsesSize: true`。

    ### 你的代码中的例子

    在你的 `_RenderSliverPersistentHeaderToBox` 代码中，`performLayout` 方法完美地诠释了这一点：

    1.  **调用 `child.layout` 并设置 `parentUsesSize: true`**:
    ```dart
    child!.layout(
      // ... constraints
      parentUsesSize: true, // 告诉框架，我接下来要用 child 的尺寸
    );
    ```

    2.  **立即使用 `child.size`**:
    紧接着，代码就根据 `child.size` 来计算 `childExtent`：
    ```dart
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    ```

    3.  **根据 `childExtent` 确定自身布局**:
    最后，使用 `childExtent` 来设置自身的 `SliverGeometry`，这决定了 `Sliver` 在滚动区域中的大小。
    ```dart
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: childExtent,
      maxPaintExtent: childExtent,
    // ...
    );
    ```

    在这个例子中，`_RenderSliverPersistentHeaderToBox` 这个 `Sliver` 的大小完全由其 `child` 的大小决定。因此，如果不设置 `parentUsesSize: true`，
    在 `debug` 模式下会触发断言失败，因为框架禁止在不声明意图的情况下读取可能不准确的子级尺寸。*/
    child!.layout(
      ExtraInfoBoxConstraints(
        // 只要constraints.scrollOffset不为0，则表示已经有内容在当前Sliver下面了（重叠了）
        // `constraints.scrollOffset` 是 `SliverConstraints` 对象的一个属性，它表示**当前 Sliver 的顶部（leading edge）** 相对于 **视口（Viewport）的顶部** 已经滚动的距离。
        //
        // 这里的组件指的是 `_RenderSliverPersistentHeaderToBox` 这个 Sliver 自身。
        //
        // 可以这样理解 `scrollOffset`：
        //
        // 1.  **所属对象**：这个 `constraints` 对象是由父级（通常是 `RenderViewport`，即可滚动区域的渲染对象）传递给当前 Sliver（`_RenderSliverPersistentHeaderToBox`）的。
        //
        // 2.  **含义**：它代表了当前 Sliver 在滚动视图中的位置状态。
        // *   当 `scrollOffset` 为 `0.0` 时，意味着这个 Sliver 的顶部与视口的顶部对齐，它还没有被向上滚动。
        // *   当 `scrollOffset` 大于 `0.0` 时，意味着用户已经向上滚动了内容，导致这个 Sliver 的顶部有一部分或者全部已经滚动到了视口的可见区域之外。这个值就是滚出视口顶部的距离。
        //
        // 在您的代码中，`constraints.scrollOffset != .0` 这个判断的目的是：
        //
        // *   检查当前 Sliver 是否已经被向上滚动。
        // *   如果被滚动了（`scrollOffset > 0`），就意味着它不再处于初始的完全可见位置。代码将这个状态（一个布尔值 `true`）通过 `ExtraInfoBoxConstraints` 传递给子 Widget。
        // *   子 Widget（通过 `SliverPersistentHeaderToBox.builder`）接收到这个名为 `fixed` 的布尔值，从而可以根据 Sliver 是否“固定”在顶部（即已经被向上滚动）来改变自身的布局或外观。
        constraints.scrollOffset != .0,
        constraints.asBoxConstraints(
          // 我们将剩余的可绘制空间作为 header 的最大高度约束传递给 LayoutBuilder
          // `constraints.remainingPaintExtent` 是 `SliverConstraints` 对象的一个属性，
          // 它表示当前 Sliver 在视口（Viewport，即可见区域）中**剩余的可绘制空间大小**。
          //
          // 简单来说，它的计算方式是：
          //
          // **视口在主轴上的总长度** - **当前 Sliver 之前的所有内容已经占用的滚动长度**。
          //
          // 在您的代码中：
          // `maxExtent: constraints.remainingPaintExtent`
          //
          // 这行代码的作用是，将视口中所有剩余的可用空间作为最大高度（或宽度，取决于滚动方向）约束，传递给 `child`。
          // 这样，`child`（通过 `LayoutBuilder`）就可以知道它最多可以延展多大，从而实现一个填满剩余可见空间的布局效果。
          maxExtent: constraints.remainingPaintExtent,
        ),
      ),
      //我们要根据child大小来确定Sliver大小，所以后面需要用到child的size信息
      parentUsesSize: true,
    );

    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    // print('###### constraints.scrollOffset:${constraints.scrollOffset} ');
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      // 固定，如果不想固定应该传 - constraints.scrollOffset
      paintOrigin: 0.0,
      paintExtent: childExtent,
      maxPaintExtent: childExtent,
    );
  }

  // 重要，如果没有重写则不会响应事件，点击测试中会用到。关于点击测试我们会在本书面介绍,
  // 读者现在只需要知道该函数应该返回 paintOrigin 的位置即可。
  @override
  double childMainAxisPosition(RenderBox child) => 0.0;
}
