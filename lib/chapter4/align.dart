import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

class AlignRoute extends StatelessWidget {
  const AlignRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            height: 120.0,
            width: 120.0,
            color: Colors.blue.shade50,
            child: const Align(
              alignment: Alignment.topRight,
              child: FlutterLogo(
                size: 60,
              ),
            ),
          ),

          ///无论Alignment还是FractionalOffset表示的是子组件在父组件中的起始位置
          ///计算为相对于坐标系原点+偏移值,都用子组件的左上角当锚点去计算好些,公式看书143页
          /// (x*childWidth/2+childWidth/2,y*childHeight/2+childHeight/2)
          /// (-1,-1)==>左上原始点,(0,0)==>中心点
          Container(
            color: Colors.purple.shade50,
            // Align背景色一定是透明,所以透过去显示底色
            child: const Align(
              widthFactor: 3, //宽度因子,为子组件的多少倍
              heightFactor: 3,
              alignment: Alignment(0, 0.0),
              child: FlutterLogo(
                size: 60,
              ),
            ).withBorder(),
          ),

          ///推荐使用FractionalOffset,坐标参考系在左上角,偏移系数常量为子组件宽高值
          Container(
            height: 120.0,
            width: 120.0,
            color: Colors.blue[50],
            child: const Align(
              alignment: FractionalOffset(1.5, 0),
              child: FlutterLogo(
                size: 60,
              ),
            ),
          ),

          DecoratedBox(
            decoration: BoxDecoration(color: Colors.red),
            child: Center(
              child: Text("xxx").withBorder(),
            ),
          ),

          /// 借助Align(Center继承自Align)把父容器的大小限制在是由子容器大小决定
          /// Align能单用来定义子组件的位置,也能用来根据子组件大小确定自身的大小[不需要结合Stack]
          const DecoratedBox(
            decoration: BoxDecoration(color: Colors.red),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text("xxx"),
            ),
          )
        ]
            .map((e) =>
                Padding(padding: const EdgeInsets.only(top: 16), child: e))
            .toList(),
      ),
    );
  }
}
