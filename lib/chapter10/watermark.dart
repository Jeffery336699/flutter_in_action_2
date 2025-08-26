import 'package:flutter/material.dart' hide Page;
import 'package:flutter_in_action_2/ext.dart';

import '../common.dart';

class WatermarkRoute extends StatelessWidget {
  const WatermarkRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage(children: [
      Page('测量文本宽高', wTextPainterTest(), showLog: true),
      Page('文本水印', wTextWaterMark(context), padding: false),
      Page('交错文本水印', wStaggerTextWaterMark(), padding: false),
      Page('水印指定偏移', wTextWaterMarkWithOffset(), padding: false),
      Page('UnconstrainedBox,水印偏移后会溢出', wTextWaterMarkWithUnconstrainedBox(),
          padding: false),
      Page('水印偏移-FittedBox', wTextWaterMarkWithFittedBox(), padding: false),
      Page('水印指定-OverflowBox', wTextWaterMarkWithOverflowBox(), padding: false),
      Page('OverflowBox示例', wOverflowBox(), padding: false),
    ]);
  }

  Widget wTextPainterTest() {
    // 我们想提前知道 Text 组件的大小
    Text text = const Text('flutter@wendux', style: TextStyle(fontSize: 18));
    // 使用 TextPainter 来测量
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    // 将 Text 组件文本和样式透传给TextPainter
    painter.text = TextSpan(text: text.data, style: text.style);
    // 开始布局测量，调用 layout 后就能获取文本大小了
    painter.layout();

    /// 自定义组件 AfterLayout 可以在布局结束后获取子组件的大小，我们用它来验证一下
    /// TextPainter 测量的宽高是否正确(理论应该是一样的,书上也是这样)
    return AfterLayout(
      callback: (RenderAfterLayout value) {
        // 输出日志
        print('text size(painter): ${painter.size}');
        print('text size(after layout): ${value.size}');
      },
      child: text,
    );
  }

  Widget wTextWaterMark(context) {
    return StatefulBuilder(builder: (context, setState) {
      return Stack(
        children: [
          wPage(onPressed: () {
            setState(() {});
          }),
          IgnorePointer(
            //IgnorePointer 它能忽略其子小部件响应指针（触摸或光标）事件
            child: WaterMark(
              painter: TextWaterMarkPainter(
                text: 'Flutter 中国 @wendux',
                padding: const EdgeInsets.only(top: 18),
                textStyle: const TextStyle(
                  color: Colors.black,
                ),
                //rotate: -20,
              ),
            ),
          ),
        ],
      );
    },);
  }

  Widget wStaggerTextWaterMark() {
    return Stack(
      children: [
        wPage(),
        IgnorePointer(
          child: WaterMark(
            painter: StaggerTextWaterMarkPainter(
              text: '《Flutter实战》',
              text2: 'wendux',
              textStyle: const TextStyle(
                fontSize: 14,
                color: Colors.black38,
              ),
              padding2: const EdgeInsets.only(left: 40),
              rotate: -10,
            ),
          ),
        ),
      ],
    );
  }

  Widget wTextWaterMarkWithOffset() {
    return Stack(
      children: [
        wPage(),
        IgnorePointer(
          child: LayoutBuilder(builder: (context, constraints) {
            print(constraints);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Transform.translate(
                offset: const Offset(-30, 0),
                child: SizedBox(
                  // constraints.maxWidth 为屏幕宽度，+30 像素
                  width: constraints.maxWidth + 30,
                  height: constraints.maxHeight,
                  child: WaterMark(
                    painter: TextWaterMarkPainter(
                      text: 'Flutter 中国 @wendux',
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                      rotate: -20,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget wTextWaterMarkWithOverflowBox() {
    Future.delayed(const Duration(milliseconds: 200), () => print('dd'));
    return Stack(
      children: [
        wPage(),
        IgnorePointer(
          child: TranslateWithExpandedPaintingArea(
            offset: const Offset(-30, 0),
            child: WaterMark(
              painter: TextWaterMarkPainter(
                text: 'Flutter 中国 @wendux',
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
                rotate: -20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///OverflowBox的布局过程没有影响父组件，只改变子组件的布局范围，因此造成了“突破父组件边界”的视觉效果
  ///例如如下的红色区域仍然是没法点击的,包括Text也是紧贴这上一个组件布局的
  Widget wOverflowBox() {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          color: Colors.blue,
          ///OverflowBox外层加个ClipRect把溢出的部分裁剪掉
          child: OverflowBox(
            maxWidth: 200,
            maxHeight: 200,
            child: Container(
              width: 150,
              height: 150,
              color: Colors.red,
            ).onTap(() {
              print('点击了红色区域');
              }),
          ).opacity(0.3),
        ),
        Text('text'),
        ],
    ),);
  }

  Widget wTextWaterMarkWithUnconstrainedBox() {
    return Stack(
      children: [
        wPage(),
        IgnorePointer(
          child: LayoutBuilder(
            builder: (_, constraints) {
              return UnconstrainedBox(
                // 把多出来的裁剪掉，这种方式也是ok的
                clipBehavior: Clip.hardEdge,
                // 这里对齐主要是从右上对齐开始，左边就没看起来那么‘呆’🥲
                alignment: Alignment.topRight,
                child: SizedBox(
                  //指定 WaterMark 宽度比屏幕长 30 像素
                  width: constraints.maxWidth + 40,
                  height: constraints.maxHeight,
                  child: WaterMark(
                    painter: TextWaterMarkPainter(
                      text: 'Flutter 中国 @wendux',
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                      rotate: 0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget wTextWaterMarkWithFittedBox() {
    return Stack(
      children: [
        wPage(),
        IgnorePointer(
          child: LayoutBuilder(
            builder: (_, constraints) {
              return FittedBox(
                // FittedBox（我来承担）会取消父组件对子组件的约束，子组件大于父组件时会缩小（类似图片的缩放效果）
                alignment: Alignment.topRight, // 通过对齐方式来实现平移效果
                fit: BoxFit.none, //不进行任何适配处理
                child: SizedBox(
                  //指定 WaterMark 宽度比屏幕长 30 像素
                  width: constraints.maxWidth + 30,
                  height: constraints.maxHeight,
                  child: WaterMark(
                    painter: TextWaterMarkPainter(
                      text: 'Flutter 中国 @wendux',
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                      rotate: -20,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget wPage({ VoidCallback? onPressed}) {
    return Center(
      child: ElevatedButton(
        child: const Text('按钮'),
        onPressed: () {
          onPressed?.call();
        },
      ),
    );
  }
}
