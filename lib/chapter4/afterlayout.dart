import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

import '../common.dart';

class AfterLayoutRoute extends StatefulWidget {
  const AfterLayoutRoute({Key? key}) : super(key: key);

  @override
  _AfterLayoutRouteState createState() => _AfterLayoutRouteState();
}

class _AfterLayoutRouteState extends State<AfterLayoutRoute> {
  String _text = 'flutter 实战 ';
  Size _size = Size.zero;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Builder(
            builder: (context) {
              ///1. 至少事件分发是在布局之后
              return GestureDetector(
                child: const Text(
                  'Text1: 点我获取我的大小',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () => print('Text1: ${context.size}'),
              );
            },
          ),
        ),
        // Optimize: 老师封装的轻松获取child的大小和位置的组件
        AfterLayout(
          callback: (RenderAfterLayout ral) {
            print('Text2： ${ral.size}, ${ral.offset}');
          },
          child: const Text('Text2：flutter@wendux'),
        ),
        Builder(builder: (context) {
          return Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            width: 100,
            height: 100,
            child: AfterLayout(
              callback: (RenderAfterLayout ral) {
                Offset offset = ral.localToGlobal(
                  Offset.zero,

                  /// context是获取到的Container的context,以他所对应的RenderObject为参考系(锚点)
                  ancestor: context.findRenderObject(),
                );
                // `&` 操作符是 `Offset` 类的一个成员，它与一个 `Size` 对象组合，创建一个 `Rect` 对象。
                //
                // 在这个例子中：
                // *   `offset` 是 `Text('A')` 相对于 `Container` 的左上角坐标。
                // *   `ral.size` 是 `Text('A')` 的尺寸（宽度和高度）。
                //
                // `offset & ral.size` 这行代码创建了一个 `Rect`（矩形）对象，该矩形的位置和大小正好就是 `Text('A')` 在其父 `Container` 中所占用的空间范围。
                //
                // **一般使用场景：**
                //
                // 当你需要在父组件坐标系中获取子组件的精确边界框（bounding box）时，这个操作非常有用。常见场景包括：
                // *   **自定义绘制（Custom Painting）：** 在子组件周围绘制高亮、边框或其它装饰。
                // *   **命中测试（Hit Testing）：** 判断触摸事件是否落在了某个特定子组件的区域内。
                // *   **定位其他组件：** 根据一个组件的位置和大小，来精确定位另一个组件（例如，实现一个跟随组件的Tooltip或弹出菜单）。
                print('A 在 Container 中占用的空间范围为：${offset & ral.size}');
              },
              child: const Text('A'),
            ),
          );
        }),
        const Divider(),
        AfterLayout(
          child: Text(_text),
          callback: (RenderAfterLayout value) {
            setState(() {
              //更新尺寸信息
              _size = value.size;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Text size: $_size ',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _text += 'flutter 实战 ';
            });
          },
          child: const Text('追加字符串'),
        ),
      ],
    ).withBorder();
  }
}
