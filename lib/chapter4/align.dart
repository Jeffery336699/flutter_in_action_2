import 'package:flutter/material.dart';

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
//          height: 120.0,
//          width: 120.0,
            color: Colors.blue.shade50,
            child: const Align(
              widthFactor: 2,
              heightFactor: 2,
              alignment: Alignment(0, 0.0),
              child: FlutterLogo(
                size: 60,
              ),
            ),
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

          const DecoratedBox(
            decoration: BoxDecoration(color: Colors.red),
            child: Center(
              child: Text("xxx"),
            ),
          ),

          /// 借助Align把父容器的大小限制在是由子容器大小决定
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
