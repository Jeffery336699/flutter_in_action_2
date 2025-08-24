import 'package:flutter/material.dart' hide Page;

import '../common.dart';

class PersistentHeaderRoute extends StatelessWidget {
  const PersistentHeaderRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage(children: [
      Page('SliverPersistentHeader示例1', wSample1(), padding: false),
      Page('SliverPersistentHeader示例2', wSample2(context), withScaffold: false),
    ]);
  }

  Widget wSample1() {
    ///1. 系统的SliverPersistentHeader时,第一个SliverPersistentHeaderDelegate的overlapsContent有问题,永远都是false(就算有重叠)
    ///   但是之后的没问题(eg,从第二个开始)
    ///2. 无论maxExtent和minExtent相等or不相等时,当滚动触发到组件SliverPersistentHeader收缩时,shrinkOffset的值都是从0到达maxExtent,
    ///   头部组件的也会在maxExtent与minExtent不同时发生UI变化
    ///3. 详情可以看这个示例的日志输出
    return CustomScrollView(
      slivers: [
        buildSliverList(),

        ///注意:在使用SliverPersistentHeader时使用的都是pinned:true,也就是固定到顶部
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate(
            maxHeight: 80,
            minHeight: 50,
            child: buildHeader(1),
          ),
        ),
        buildSliverList(),
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate.fixedHeight(
            height: 50,
            child: buildHeader(2),
          ),
        ),
        buildSliverList(20),
      ],
    );
  }
  /// 好的，我们来详细解释一下 `SliverPersistentHeader` 中的 `pinned` 和 `floating` 属性。
  ///
  /// 这两个属性都用于控制 `Sliver` 组件在 `CustomScrollView` 中的滚动行为，但它们关注的方面不同。
  ///
  /// ### `pinned` 属性
  ///
  /// `pinned` 决定了当 header 滚动到视口（viewport）的起始边缘时，是否应该“钉”在那里，而不是继续滚出屏幕。
  ///
  /// *   **`pinned: true`**:
  /// 当向上滚动时，header 会随着内容一起滚动。当 header 的顶部到达 `CustomScrollView` 的顶部时，它会“钉”在那里（收缩到 `minExtent` 的高度），而它下面的内容会继续滚动。header 会一直保持可见，直到你向相反方向滚动，把它重新“展开”。
  /// *   **`pinned: false` (默认值)**:
  /// 当向上滚动时，header 会像列表中的普通项目一样，完全滚出屏幕外。
  ///
  /// **简单来说，`pinned` 控制 header 是否在滚动到顶部后“固定”住。**
  ///
  /// ### `floating` 属性
  ///
  /// `floating` 决定了当用户开始向下滚动（即，查看已经滚出屏幕上方的内容）时，header 如何重新出现。这个属性只有在 header 已经滚出屏幕一部分或全部时才有意义。
  ///
  /// *   **`floating: true`**:
  /// 即使用户只向下滚动了一点点，header 也会立刻开始从顶部滑入视图。它不需要用户滚动到列表的最顶部才能出现。
  /// *   **`floating: false` (默认值)**:
  /// header 只有在用户将滚动视图滚动到最顶部，即 header 的原始位置完全可见时，才会重新出现。
  ///
  /// **简单来说，`floating` 控制已经滚出屏幕的 header 是否能“浮动”回来。**
  ///
  /// ---
  ///
  /// ### 区别与组合
  ///
  /// | 组合                  | 行为描述                                                                                                                               | 适用场景                                                               |
  /// | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
  /// | `pinned: false` (默认) <br> `floating: false` (默认) | **标准行为**：Header 像普通列表项一样，向上滚出，向下滚动到顶部才出现。                                                              | 简单的、不需要常驻的 Header，例如文章顶部的一个大图。                  |
  /// | `pinned: true` <br> `floating: false`        | **固定 Header**：向上滚动时，Header 会收缩并固定在顶部。向下滚动时，只有列表滚动到最顶部，Header 才会完全展开。                               | 需要始终在顶部显示标题或选项卡的场景，这是最常见的固定头。               |
  /// | `pinned: false` <br> `floating: true`        | **浮动 Header**：向上滚出屏幕。但只要一开始向下滚动，Header 就会立刻出现。它不会固定在顶部，会随着向下滚动再次滚出屏幕。             | 适用于那些不需要一直固定，但需要能被快速访问的工具栏，例如一个搜索框。 |
  /// | `pinned: true` <br> `floating: true`        | **固定且浮动的 Header**：向上滚动时固定在顶部。当列表向下滚动时，Header 会立刻从收缩状态展开。这是 `SliverAppBar` 中非常经典的组合。 | 既要最大化内容区域，又要让用户能随时通过轻微的下滚操作快速唤出完整的 AppBar。 |
  ///
  /// ### 如何在项目中选择？
  ///
  /// 1.  **如果你的 Header 必须始终可见（例如页面标题）**：
  /// 使用 `pinned: true`。这是最基本的需求。
  ///
  /// 2.  **如果你希望在节省屏幕空间的同时，让用户能快速再次访问 Header（例如社交应用中的 AppBar）**：
  /// 使用 `pinned: true` 和 `floating: true`。这样向上滚动时 Header 会收缩，为内容腾出空间；而一旦用户想看 AppBar，只需轻微向下滚动即可。
  ///
  /// 3.  **如果你的 Header 只是一个装饰或临时信息，不需要常驻**：
  /// 使用默认的 `pinned: false` 和 `floating: false`。
  ///
  /// 4.  **如果你有一个不需要固定的“快捷操作栏”（如搜索框），希望它滚出后能被快速唤回**：
  /// 使用 `pinned: false` 和 `floating: true`。
  Widget wSample2(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: ColoredBox(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              ///floating:true就是随便滑动出去多远,一往下滑动就能出来
              SliverPersistentHeader(
                floating: false, /// 是否往下立马出来. true:无论滚动多远立马出来;false:滚动到顶部才出来
                delegate: SliverHeaderDelegate.fixedHeight(
                  height: 50,
                  child: const TextField(),
                ),
              ),
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: const SliverAppBar(
                  title: Text('示例二'),
                  pinned: true,
                  collapsedHeight: 56,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverHeaderDelegate.fixedHeight(
                  height: 50,
                  child: buildHeader(2),
                ),
              ),
              buildSliverList(30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(int i) {
    return GestureDetector(
      key: ValueKey(i),
      onTap: () => print('header $i'),
      child: Container(
        color: Colors.lightBlue.shade200,
        alignment: Alignment.centerLeft,
        child: Text("PersistentHeader $i"),
      ),
    );
  }
}
