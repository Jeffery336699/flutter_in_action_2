import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

import '../common.dart';

class ResponsiveColumn extends StatelessWidget {
  const ResponsiveColumn({Key? key, required this.children}) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    ///通过LayoutBuilder拿到父组件对子组件的约束信息,然后根据约束信息构建不同的布局(一种响应式的思维)
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        print('LayoutBuilder---> ${constraints.maxWidth}');
        if (constraints.maxWidth < 200) {
          return Column(children: children, mainAxisSize: MainAxisSize.min);
        } else {
          var _children = <Widget>[];
          for (var i = 0; i < children.length; i += 2) {
            if (i + 1 < children.length) {
              _children.add(Row(
                children: [children[i], children[i + 1]],
                mainAxisSize: MainAxisSize.min,
              ));
            } else {
              _children.add(children[i]);
            }
          }
          return Column(children: _children, mainAxisSize: MainAxisSize.min);
        }
      },
    );
  }
}

class LayoutBuilderRoute extends StatelessWidget {
  const LayoutBuilderRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return LayoutLogPrint(child:Text("xx"*20000));
    var _children = List.filled(6, const Text("A"));
    // Column在本示例中在水平方向的最大宽度为屏幕的宽度
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 190, child: ResponsiveColumn(children: _children)),
        ResponsiveColumn(children: _children),
        const LayoutLogPrint(child: Text("flutter@wendux")),
        //CustomSingleChildLayout
      ],
    ).withBorder();
  }
}
