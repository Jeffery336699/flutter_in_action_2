import 'package:flutter/material.dart' hide Page;

import '../common.dart';

class NestedScrollViewRoute extends StatelessWidget {
  const NestedScrollViewRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage(children: [
      Page('嵌套 ListView', const NestedListView(),
          withScaffold: false),
      Page(
          'Snap 效果的AppBar(bug版)', const SnapAppBarWithBug(),
          withScaffold: false),
      Page('Snap 效果的AppBar（无bug）', const SnapAppBar2(),
          withScaffold: false),
      Page('嵌套 TabBarView', const NestedTabBarView1(),
          withScaffold: false),
      Page('复杂的嵌套 TabBarView', const NestedTabBarView2(),
          withScaffold: false, showLog: false),
    ]);
  }
}

class NestedListView extends StatelessWidget {
  const NestedListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NestedScrollView设计时就分为header和body两部分
      body: NestedScrollView(
        // `headerSliverBuilder` 是 `NestedScrollView` 的一个必需属性，它是一个构建器函数，用于构建 `NestedScrollView` 的头部（Header）。
        //
        // ### 作用和参数
        //
        // *   **作用**: 它返回一个 `Widget` 列表，这个列表里的 `Widget` 必须是 "sliver" 类型（例如 `SliverAppBar`, `SliverList`, `SliverPersistentHeader` 等）。这些 sliver 构成了 `NestedScrollView` 的外部可滚动区域，通常显示在 `body` 内容的上方。当用户滚动时，头部和主体（`body`）会协调滚动。
        // *   **`BuildContext context`**: 构建上下文。
        // *   **`bool innerBoxIsScrolled`**: 一个布尔值，表示内部的可滚动视图（即 `body` 部分）是否已经开始滚动。这个参数非常有用，你可以根据它来改变头部的外观。例如，当内部列表开始滚动时，给 `SliverAppBar` 添加一个阴影（elevation），就像示例代码第 36 行 `forceElevated: innerBoxIsScrolled` 所做的那样。
        //
        // ### 常见使用场景
        //
        // `NestedScrollView` 和 `headerSliverBuilder` 主要用于实现复杂的嵌套滚动效果，特别是当一个可滚动的头部需要和另一个可滚动的主体部分联动时。
        //
        // 1.  **可折叠的 AppBar**: 创建一个可以随着页面内容滚动而展开或收起的 `SliverAppBar`。这是最常见的用法，如文件中的 `SnapAppBarWithBug` 示例。
        // 2.  **吸顶的 TabBar**: 在 `SliverAppBar` 下方放置一个 `TabBar`，当用户向下滚动时，`SliverAppBar` 可以收起，但 `TabBar` 会固定在页面顶部。文件中的 `NestedTabBarView1` 和 `NestedTabBarView2` 就是很好的例子。
        // 3.  **复杂的个人资料页**: 页面顶部可能包含用户头像、背景图和一些统计信息，这些内容作为头部可以随下方的内容列表（如帖子、动态等）一起滚动，并可能带有折叠或吸顶效果。
        // 4.  **任何需要将多个滚动视图（Slivers）组合在一个协调的滚动体验中的场景**。
        headerSliverBuilder: (BuildContext context,
            bool innerBoxIsScrolled) {
          // 返回一个 Sliver 数组
          return <Widget>[
            SliverAppBar(
              title: const Text('嵌套ListView'),
              pinned: true,
              forceElevated: innerBoxIsScrolled,
            ),
            buildSliverList(), //构建一个 sliverList
          ];
        },
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          //  在 `NestedScrollView` 中，`body` 里的可滚动组件（如此处的 `ListView`）使用 `ClampingScrollPhysics` 是为了确保内部和外部滚动视图能够正确地协调工作。
          //
          //     它的主要作用是：
          //
          //     1.  **禁止内部列表的越界滚动效果**：像 iOS 上默认的 `BouncingScrollPhysics` 会在列表滚动到顶部或底部时产生回弹效果。
          //     在 `NestedScrollView` 中，这种回弹会与外部 `SliverAppBar` 的滚动逻辑冲突，导致不连贯的滚动体验。`ClampingScrollPhysics`
          //     会在列表滚动到边缘时停止，并显示一个“光晕”效果（在 Android 上），而不会产生位移。
          //
          //     2.  **保证滚动控制权的平滑交接**：`NestedScrollView` 的工作机制是，当外部的 `header` (如 `SliverAppBar`)
          //     滚动到极限（例如完全折叠或展开）后，滚动事件会传递给内部的 `body` (`ListView`)。通过使用 `ClampingScrollPhysics`，
          //     当内部 `ListView` 滚动到其顶部边缘时，它会立刻停止滚动，并将滚动控制权“交还”给外部的 `NestedScrollView`，这样用户继续向下滑动时，
          //     `SliverAppBar` 就能平滑地展开。
          //
          // 简单来说，设置 `physics: const ClampingScrollPhysics()` 是为了让内部 `ListView` 的滚动行为更“规矩”，
          // 从而避免与 `NestedScrollView` 的复杂滚动协调机制发生冲突，确保整体滚动的流畅和可预测性。
          physics: const ClampingScrollPhysics(),
          //重要
          itemCount: 30,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 50,
              child: Center(child: Text('Item $index')),
            );
          },
        ),
      ),
    );
  }
}

class SnapAppBarWithBug extends StatelessWidget {
  const SnapAppBarWithBug({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // `CustomScrollView` 和 `NestedScrollView` 都是 Flutter 中用于构建复杂滚动效果的强大组件，但它们的设计目标和应用场景有显著区别。
    //
    // ### 核心区别
    //
    // *   **`CustomScrollView`**: 用于在 **单个视口** 中组合多种不同类型的滚动列表（Slivers）。它的所有直接子组件都必须是 "Sliver" 类型的 Widget，
    //        如 `SliverAppBar`、`SliverList`、`SliverGrid` 等。它本身只管理一个滚动区域。
    // *   **`NestedScrollView`**: 专门用于创建 **嵌套滚动** 效果，即一个外部滚动视图（Header）和一个内部滚动视图（Body）协同滚动。它将滚动区域明确地分为两部分：`headerSliverBuilder` 和 `body`。
    //
    // ---
    //
    // ### 对比分析
    //
    // | 特性 | `CustomScrollView` | `NestedScrollView` |
    // | :--- | :--- | :--- |
    // | **结构** | 单一滚动区域，所有子组件都是 Slivers。 | 两个滚动区域：`headerSliverBuilder`（外部，Slivers）和 `body`（内部，通常是另一个可滚动组件）。 |
    // | **滚动控制器** | 拥有 **一个** `ScrollController` 来控制整个滚动视图。 | **内部协调内外两个滚动视图**。它内部管理着复杂的滚动逻辑，将外部和内部的滚动无缝衔接。开发者通常只给 `NestedScrollView` 提供一个 `controller` 来监听外部滚动，而不需要（也不应该）分别控制内部和外部的滚动。 |
    // | **主要应用场景** | 1.  需要将不同类型的滚动列表（如列表、网格）混合在同一滚动视图中的页面。<br>2.  实现复杂的视差滚动和自定义滚动效果的个人资料页或详情页。 | 1.  **带吸顶 `TabBar` 的 `TabBarView`**：这是最经典的应用场景。`SliverAppBar` 向上滚动收起，`TabBar` 固定在顶部，而下方的 `TabBarView` 中的每个页面都可以独立滚动。<br>2.  需要一个可折叠的头部，并且头部下方的主体内容本身也是一个复杂的、可滚动的列表。 |
    // | **使用技巧** | 直接在 `slivers` 属性中放置 `SliverAppBar`, `SliverList`, `SliverGrid` 等即可。 | 1.  **`headerSliverBuilder`**: 构建外部可滚动的头部（必须返回 Slivers 列表）。<br>2.  **`body`**: 放置内部可滚动视图，如 `ListView` 或 `TabBarView`。<br>3.  **滚动物理效果**: 内部滚动视图（`body`）通常需要设置 `physics: const ClampingScrollPhysics()` 来保证内外滚动交接的流畅性。<br>4.  **解决重叠问题**: 当 `header` 中有 `floating` 和 `snap` 效果的 `SliverAppBar` 时，需要配合 `SliverOverlapAbsorber` 和 `SliverOverlapInjector` 来防止 `header` 收起时遮挡 `body` 的内容（如您代码中的 `SnapAppBar2` 和 `NestedTabBarView1` 示例）。 |
    //
    // ### 总结
    //
    // *   如果你的需求是 **在一个滚动视图里混合不同样式的列表**，比如一个伸缩的 AppBar 紧跟着一个网格，然后是一个列表，那么 `CustomScrollView` 是最佳选择。
    // *   如果你的需求是 **一个滚动区域（如 `TabBarView`）嵌套在另一个滚动区域（带有 `SliverAppBar` 的外部容器）内部**，并且希望它们能够协调滚动，那么必须使用 `NestedScrollView`。
    //
    // 简单来说：`CustomScrollView` 是“**万物皆可为 Sliver**”，而 `NestedScrollView` 是“**头部和身体要联动**”。
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context,
            bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: true,
              snap: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  "./imgs/sea.png",
                  fit: BoxFit.cover,
                ),
              ),
              forceElevated: innerBoxIsScrolled,
            )
          ];
        },
        body: Builder(builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[buildSliverList(100)],
          );
        }),
      ),
    );
  }
}

class SnapAppBar2 extends StatefulWidget {
  const SnapAppBar2({Key? key}) : super(key: key);

  @override
  State<SnapAppBar2> createState() => _SnapAppBar2State();
}

class _SnapAppBar2State extends State<SnapAppBar2> {
  late SliverOverlapAbsorberHandle handle;

  void onOverlapChanged() {
    // 打印 overlap length
    print(handle.layoutExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context,
            bool innerBoxIsScrolled) {
          /**
           * NestedScrollView.sliverOverlapAbsorberHandleFor 是 NestedScrollView 的一个辅助工具方法，
           * 用于解决复杂的嵌套滚动场景下的偏移量协调问题。它主要与 SliverOverlapAbsorber 和 SliverOverlapInjector 配合使用，
           * 解决滑动冲突以及内容遮挡问题，在动态头部、吸顶效果以及嵌套滑动优化等场景中非常实用。
           */
          handle = NestedScrollView
              .sliverOverlapAbsorberHandleFor(context);
          handle.removeListener(onOverlapChanged);
          handle.addListener(onOverlapChanged);
          return <Widget>[
            SliverOverlapAbsorber(
              handle: handle,
              sliver: SliverAppBar(
                floating: true,
                snap: true,
                // pinned: true,  // 放开注释，然后看日志
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    "./imgs/sea.png",
                    fit: BoxFit.cover,
                  ),
                ),
                forceElevated: innerBoxIsScrolled,
              ),
            ),
          ];
        },
        body: LayoutBuilder(
            builder: (BuildContext context, cons) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(handle: handle),
              buildSliverList(100)
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    // 移除监听器
    handle.removeListener(onOverlapChanged);
    super.dispose();
  }
}

class NestedTabBarView1 extends StatelessWidget {
  const NestedTabBarView1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _tabs = <String>['猜你喜欢', '今日特价', '发现更多'];
    // 构建 tabBar
    return DefaultTabController(
      length: _tabs.length, // This is the number of tabs.
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context,
              bool innerBoxIsScrolled) {
            return <Widget>[
              //SliverOverlapAbsorber和SliverOverlapInjector再加上floating: true,snap: true完美实现嵌套滚动不遮挡的效果
              SliverOverlapAbsorber(
                handle: NestedScrollView
                    .sliverOverlapAbsorberHandleFor(
                        context),
                sliver: SliverAppBar(
                  title: const Text('商城'),
                  floating: true,
                  snap: true,
                  // pinned: true,
                  forceElevated: true,
                  bottom: TabBar(
                    tabs: _tabs
                        .map((String name) =>
                            Tab(text: name))
                        .toList(),
                  ),
                ),
              ),

              // SliverAppBar(
              //   title: const Text('商城'),
              //   // floating: true,
              //   // snap: true,
              //   pinned: true,
              //   forceElevated: true,
              //   bottom: TabBar(
              //     tabs: _tabs.map((String name) => Tab(text: name)).toList(),
              //   ),
              // ),
            ];
          },
          body: TabBarView(
            children: _tabs.map((String name) {
              return Builder(
                builder: (BuildContext context) {
                  return CustomScrollView(
                    key: PageStorageKey<String>(name),
                    slivers: <Widget>[
                      SliverOverlapInjector(
                        handle: NestedScrollView
                            .sliverOverlapAbsorberHandleFor(
                                context),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: buildSliverList(50),
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NestedTabBarView2 extends StatelessWidget {
  const NestedTabBarView2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _tabs = <String>['猜你喜欢', '今日特价', '发现更多'];
    // 构建 tabBar
    return DefaultTabController(
      length: _tabs.length, // This is the number of tabs.
      child: Theme(
        data: Theme.of(context)
            .copyWith(brightness: Brightness.dark),
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context,
                bool innerBoxIsScrolled) {
              return <Widget>[
                const SliverAppBar(
                  title:
                      Text('Floating Nested SliverAppBar'),
                  pinned: true,
                  elevation: 0,
                  //forceElevated: innerBoxIsScrolled,
                ),
                buildSliverList(5),

                ///固定效果在这个header里
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverHeaderDelegate.builder(
                    maxHeight: 56,
                    minHeight: 56,
//       `overlapsContent` 是一个布尔值参数，它表示 `SliverPersistentHeader` 的内容是否与滚动视图中的其他内容（通常是它下面的内容）发生了重叠。
//
// 具体来说：
//
// *   当用户向上滚动，导致 `SliverPersistentHeader` 下方的内容开始滑入到其后面时，`overlapsContent` 会变为 `true`。
// *   在内容没有滚动到 `SliverPersistentHeader` 后面时，`overlapsContent` 为 `false`。
//
// 在您的代码中，这个参数被用来动态地改变 `TabBar` 所在容器的样式：
//
// *   **颜色 (color)**: 当 `overlapsContent` 为 `true` 时，背景色变为 `Colors.blue[300]`，否则使用主题的 `canvasColor`。
// *   **阴影 (elevation)**: 当 `overlapsContent` 为 `true` 时，`Material` 组件的海拔（`elevation`）被设置为 `4`，从而显示出阴影，以在视觉上将固定的 `Header` 与其下方滚动的内容区分开。
//
// 这是一个非常实用的特性，用于在 `Header` 从普通状态变为“悬浮”在内容之上状态时，提供清晰的视觉反馈。
                    builder: (BuildContext context,
                        double shrinkOffset,
                        bool overlapsContent) {
                      return Material(
                        child: Container(
                          color: overlapsContent
                              ? Colors.blue[300]
                              : Theme.of(context)
                                  .canvasColor,
                          child: buildTabBar(_tabs),
                        ),
                        elevation: overlapsContent ? 4 : 0,
                        shadowColor: Theme.of(context)
                            .appBarTheme
                            .shadowColor,
                      );
                    },
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: _tabs.map((String name) {
                return Builder(
                  builder: (BuildContext context) {
                    return CustomScrollView(
                      key: PageStorageKey<String>(name),
                      physics:
                          const ClampingScrollPhysics(),
                      slivers: <Widget>[
                        SliverPadding(
                          padding:
                              const EdgeInsets.all(8.0),
                          sliver: buildSliverList(30),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTabBar(List<String> tabs) {
    return TabBar(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.black38,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: const UnderlineTabIndicator(
        borderSide:
            BorderSide(width: 2.0, color: Colors.blue),
        insets: EdgeInsets.only(bottom: 0),
      ),
      tabs: tabs
          .map((String name) => Tab(text: name))
          .toList(),
    );
  }
}
