import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

class WrapAndFlowRoute extends StatelessWidget {
  const WrapAndFlowRoute({Key? key}) : super(key: key);
  // `Wrap` 和 `Flow` 都是用于实现流式布局的组件，但它们在实现方式和使用场景上有所不同。
  //
  // ### 实现方式的不同
  //
  // 1.  **`Wrap`**:
  // *   是一个高级别的、开箱即用的组件。
  // *   它会自动处理子组件的布局、换行和间距。你只需要提供子组件列表以及 `spacing` (主轴间距) 和
  //     `runSpacing` (交叉轴间距) 等属性，`Wrap` 就会为你完成所有复杂的计算。
  // *   使用起来非常简单方便，适用于大多数常见的流式布局场景。
  //
  // 2.  **`Flow`**:
  // *   是一个低级别的、需要自定义布局逻辑的组件。
  // *   它本身不执行任何布局，而是将布局的控制权委托给一个 `FlowDelegate`。
  // *   你必须自己实现 `FlowDelegate`，在 `paintChildren` 方法中手动计算和定位每一个子组件的位置。这提供了极高的灵活性和性能优化的可能性。
  // *   由于布局逻辑与子组件的构建过程分离，`Flow` 在处理复杂或大量子组件的布局时性能通常更高。
  //
  // ### 实战项目中的建议
  //
  // *   **优先使用 `Wrap`**:
  // 对于绝大多数流式布局需求，比如标签云、图片墙、选项标签等，`Wrap` 都是首选。它代码量少，易于理解和维护，能快速实现功能。
  //
  // *   **在以下情况考虑使用 `Flow`**:
  // 1.  **复杂的自定义布局**: 当你需要实现 `Wrap` 无法做到的不规则布局时，例如圆形菜单、重叠效果或者像你代码中那样自定义的网格流式布局。
  // 2.  **极致的性能优化**: 当 `Wrap` 中有非常大量的子组件，并且你发现布局性能成为瓶颈时。通过自定义 `FlowDelegate`，
  //     你可以实现更高效的布局算法，并利用 `shouldRepaint` 等方法精确控制重绘时机，从而优化性能。
  //
  // ### 总结建议
  //
  // **简单来说，先用 `Wrap`，`Wrap` 搞不定或者性能不满足要求了，再用 `Flow`。**
  //
  // *   **`Wrap`** = 方便快捷，满足 90% 的场景。
  // *   **`Flow`** = 强大灵活，为 10% 的复杂场景和性能优化而生。
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [buildWrap(), buildFlow()],
    );
  }

  Widget buildWrap() {
    return const Wrap(
      spacing: 8.0, // 主轴(水平)方向间距
      runSpacing: 4.0, // 纵轴（垂直）方向间距
      alignment: WrapAlignment.center, //沿主轴方向居中
      children: <Widget>[
        Chip(
          avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('A')),
          label: Text('Hamilton'),
        ),
        Chip(
          avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('M')),
          label: Text('Lafayette'),
        ),
        Chip(
          avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('H')),
          label: Text('Mulligan'),
        ),
        Chip(
          avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('J')),
          label: Text('Laurens'),
        ),
      ],
    );
  }

  Widget buildFlow() {
    ///Flow展示自绘制方式(FlowDelegate中)
    return Flow(
      delegate: TestFlowDelegate(margin: const EdgeInsets.all(10.0)),
      children: <Widget>[
        Container(
          width: 80.0,
          height: 80.0,
          color: Colors.red,
        ),
        Container(
          width: 80.0,
          height: 80.0,
          color: Colors.green,
        ),
        Container(
          width: 80.0,
          height: 80.0,
          color: Colors.blue,
        ),
        Container(
          width: 80.0,
          height: 80.0,
          color: Colors.yellow,
        ),
        Container(
          width: 80.0,
          height: 80.0,
          color: Colors.brown,
        ),
        Container(
          width: 80.0,
          height: 80.0,
          color: Colors.purple,
        ),
      ],
    ).withBorder();
  }
}

class TestFlowDelegate extends FlowDelegate {
  EdgeInsets margin;

  TestFlowDelegate({this.margin = EdgeInsets.zero});

  double width = 0;
  double height = 0;

  @override
  void paintChildren(FlowPaintingContext context) {
    // Optimize: 自定义网格布局的既视感
    var x = margin.left;
    var y = margin.top;
    //计算每一个子widget的位置
    for (int i = 0; i < context.childCount; i++) {
      var w = context.getChildSize(i)!.width + x + margin.right;
      if (w < context.size.width) {
        context.paintChild(i, transform: Matrix4.translationValues(x, y, 0.0));
        x = w + margin.left;
      } else {
        x = margin.left;
        y += context.getChildSize(i)!.height + margin.top + margin.bottom;
        //绘制子widget(有优化)
        context.paintChild(i, transform: Matrix4.translationValues(x, y, 0.0));
        x += context.getChildSize(i)!.width + margin.left + margin.right;
      }
    }
  }

  @override
  Size getSize(BoxConstraints constraints) {
    // 指定Flow的大小，简单起见我们让宽度竟可能大，但高度指定为200，
    // 实际开发中我们需要根据子元素所占用的具体宽高来设置Flow大小
    return const Size(double.infinity, 200.0);
  }

  @override
  bool shouldRepaint(FlowDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
