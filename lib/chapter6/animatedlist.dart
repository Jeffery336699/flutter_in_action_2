import 'package:flutter/material.dart';

class AnimatedListRoute extends StatefulWidget {
  const AnimatedListRoute({Key? key}) : super(key: key);

  @override
  _AnimatedListRouteState createState() => _AnimatedListRouteState();
}

class _AnimatedListRouteState extends State<AnimatedListRoute> {
  var data = <String>[];

  /// 表示当前已经计数到哪里了
  int counter = 5;

  final globalKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    for (var i = 0; i < counter; i++) {
      data.add('${i + 1}');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedList(
          key: globalKey,
          initialItemCount: data.length,
          itemBuilder: (
            BuildContext context,
            int index,
            Animation<double> animation,
          ) {
            print('itemBuilder , value: ${animation.value}'); //==> 1.0
            ///build item时针对每个item的动画
            return FadeTransition(
              opacity: animation,
              child: buildItem(context, index),
            );
          },
        ),
        buildAddBtn(),
      ],
    );
  }

  Widget buildAddBtn() {
    return Positioned(
      child: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          data.add('${++counter}');
          globalKey.currentState!.insertItem(data.length - 1);
          print('添加 $counter');
        },
      ),
      bottom: 30,
      left: 0,
      right: 0,
    );
  }

  Widget buildItem(context, index) {
    String char = data[index];
    return ListTile(
      // 数字不会重复，所以作为Key
      key: ValueKey(char),
      title: Text(char),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        // 点击时删除
        onPressed: () => onDelete(context, index),
      ),
    );
  }

  void onDelete(context, index) {
    setState(() {
      globalKey.currentState!.removeItem(
        index,
        (context, animation) {
          // 删除过程执行的是反向动画，animation.value 会从1变为0
          var item = buildItem(context, index);
          print('删除 ${data[index]}');

          ///①数据层移出数据
          data.removeAt(index);

          ///让透明度变化的更快一些
          ///②UI层动画
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              //       `curve: const Interval(0.5, 1.0)` 的作用是让 `FadeTransition`（淡出动画）只在整个删除动画过程的前半部分执行。
              //
              // `removeItem` 提供的 `animation` 的值会从 1.0 变为 0.0。
              //     *   `Interval(0.5, 1.0)` 会将这个动画过程映射到 `animation.value` 在 1.0 和 0.5 之间的时段。
              // *   当 `animation.value` 从 1.0 降到 0.5 时，`FadeTransition` 的 `opacity`（不透明度）会从 1.0 降到 0.0，项目淡出。
              // *   当 `animation.value` 从 0.5 继续降到 0.0 时，`opacity` 保持为 0.0，即项目已经完全透明。
              //
              // 与此同时，`SizeTransition`（尺寸变化动画）在整个动画期间（`animation.value` 从 1.0 到 0.0）都在执行，使项目的高度不断缩小。
              //
              // 总的效果是：项目先快速淡出，然后在完全透明的状态下继续收缩消失。这可以创造出比简单的同时淡出和收缩更细致的视觉效果。
              curve: const Interval(0.5, 1.0),
            )..addListener(() {
              // Optimize: 删除最后一个元素时得日志打印（避免其他元素得干扰）
              // 删除 5
              // ==> 0.91667
              // ==> 0.8333349999999999
              // ==> 0.75
              // ==> 0.66667
              // ==> 0.5833349999999999
              // ==> 0.5
              // ==> 0.41667
              // ==> 0.33333500000000005
              // ==> 0.2500000000000001
              // ==> 0.16666999999999998
              // ==> 0.08333500000000005
              // ==> 0.0
              // ==> 0.0
              print('==> ${animation.value}');
              }),
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: 0.0,
              child: item,
            ),
          );
        },
        duration: const Duration(milliseconds: 200),
      );
    });
  }
}
