import 'package:flutter/material.dart';

import '../common.dart';

class CustomPaintRoute extends StatelessWidget {
  const CustomPaintRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ///RepaintBoundary简单认为这样做可以生成一个新的画布,避免ElevatedButton点击时(有水波纹)导致刷新整个画布
          RepaintBoundary(
            child: CustomPaint(
              size: const Size(300, 300), //指定画布大小
              painter: MyPainter(),
            ),
          ),
          RepaintBoundary(
              child: ElevatedButton(
            onPressed: () {},
            child: const Text("刷新"),
          ))
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print('MyPainter paint');
    var rect = Offset.zero & size;
    print('rect:$rect');
    //画棋盘
    drawChessboard(canvas, rect);
    //画棋子
    drawPieces(canvas, rect);
  }

  // 在实际场景中正确使用此方法可以避免重绘开销，我们简单的返回false;因为此时的棋盘与旗子都是固定的(为的是展示给我们看),为了提高性能直接返回false(不需要重绘)
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
