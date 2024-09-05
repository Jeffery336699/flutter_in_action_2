import 'package:flutter/material.dart';

// ignore: slash_for_doc_comments
/**
 *  FractionalTranslation是一个Flutter小部件，它能够根据其子小部件的相对大小（即其宽度和高度的分数）来平移（即移动）其子小部件
 *  需要注意的是，因为FractionalTranslation
    仅影响其子部件的绘制位置，而不改变其占用的布局空间，因此它可能会导致子部件在绘制时超出父级容器的边界。
 */
class FTRoute extends StatefulWidget {
  const FTRoute({Key? key}) : super(key: key);

  @override
  State<FTRoute> createState() => _FTRouteState();
}

class _FTRouteState extends State<FTRoute> {
  Offset offset = const Offset(0.0, 0.0);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // 在这里使用FractionalTranslation
        FractionalTranslation(
          translation: offset,
          // 将FractionalTranslation的子Widget设置为一个蓝色方块
          child: Container(
            width: 100.0,
            height: 100.0,
            color: Colors.blue,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              // Offset(0.5, 0.5)表示向右移动子Widget一半的宽度，向下移动一半的高度。
              offset = const Offset(0.5, 0.5);
            });
          },
          child: const Text('点击我'),
        )
      ],
    );
  }
}
