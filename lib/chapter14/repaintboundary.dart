import 'package:flutter/material.dart';

class RepaintBoundaryTest extends StatefulWidget {
  const RepaintBoundaryTest({Key? key}) : super(key: key);

  @override
  _RepaintBoundaryTestState createState() => _RepaintBoundaryTestState();
}

class _RepaintBoundaryTestState extends State<RepaintBoundaryTest> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Builder(builder: (context) {
          print("CustomPaint build $hashCode");
          return RepaintBoundary(
            child: CustomPaint(
              painter: OutlinePainter(),
              child: CustomPaint(
                size: const Size(50, 50),
                painter: OutlinePainter(),
              ),
            ),
          );
        }),
        RepaintBoundary(
          child: ElevatedButton(
            onPressed: () {
              /**
               * 父容器的setState与markNeedsPaint，对触发RepaintBoundary的重绘影响不同
               * 1. setState是在很高层度的从上到下的build、layout、draw,站在更高一层，会触发整个树的重构
               *    ①、如果绘制相关的eg CustomPainter,根据shouldRepaint返回值，来决定RepaintBoundary内是否需要重绘
               *    ②、其实上面的①的原因还是因为子组件的build重建了，紧接着决定是否需要重绘子组件
               * 2. 而markNeedsPaint是在draw阶段，在触发当前节点(指context所对应的widget-父容器)的重绘同时
               *    ①、如果子孙阶段存在包裹RepaintBoundary，会阻止子孙节点的重绘，无
               *      论绘制类API eg、CustomPainter的shouldRepaint返回什么（layer另起隔绝了）
               *    ②、如果子孙阶段没有RepaintBoundary包裹，会总会触发子孙阶段的重绘（其实最终原因是在同一个layer上）
               */
              setState(() {});
              // context.findRenderObject()!.markNeedsPaint();
            },
            child: const Text("setState"),
          ),
        )
      ],
    );
  }
}

class OutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print("paint $hashCode");
    var paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = Colors.black;
    canvas.drawRect(const Offset(10, 0) & size, paint);
  }

  // 返回true，rebuild时，painter会重新构建一个新实例
  // 返回false, 表示即使Painter实例发生变化也不需要重新绘制。
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
