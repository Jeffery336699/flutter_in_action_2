import 'package:flutter/material.dart' hide Page;

import '../common.dart';

class StackEventTest extends StatelessWidget {
  const StackEventTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage(children: [
      Page('事件共享', const StickerTest()),
      Page('水印', const _WaterMarkTest(), padding: false),
      Page('HitTestBehaviorTest', const HitTestBehaviorTest(), padding: false),
      Page('所有子节点都可以响应事件', const AllChildrenCanResponseEvent()),
      Page('手势', const GestureHitTestBlockerTest()),
    ]);
  }
}

class HitTestBehaviorTest extends StatelessWidget {
  const HitTestBehaviorTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('点击屏幕空白区域');
    return Stack(
      children: [
        wChild(1),

        ///只有2添加IgnorePointer后，1才会输出
        wChild(2),
      ],
    );
  }

  Widget wChild(int index) {
    return Listener(
      ///opaque（不透明）:hitTestSelf返回true
      ///组件通过命中测试(对外须有其表,真正能handleEvent还得看是否有添加到hitTestResult中)
      ///这样后续的兄弟节点就收不到hitTest测试了(可悲~)
      // behavior: HitTestBehavior.opaque, // 放开此行，点击只会输出 2
      ///translucent(透明):无论hitTarget结果如何,当前节点都会被添加到hitTestResult中(务实派)
      behavior: HitTestBehavior.translucent, // 放开此行，点击会同时输出 2 和1
      onPointerDown: (e) => print(index),
      child: const SizedBox.expand(child: Center(child: Text("点击屏幕空白区域"),),), //SizedBox没有子元素,当它被点击时,hitTest返回false.
    );
  }
}

class AllChildrenCanResponseEvent extends StatelessWidget {
  const AllChildrenCanResponseEvent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ///1、0都不能输出（你并不想要响应事件，捂嘴🥲）
        // IgnorePointer(child: wChild(1, 200)),
        // IgnorePointer(child: wChild(0, 200)),

        ///HitTestBlocker是老师封装的组件，以后为兄弟节点都能响应事件（1，2都能输出）
        // HitTestBlocker(child: wChild(1, 200)),
        // HitTestBlocker(child: wChild(2, 200)),

        ///HitTestBlocker只能通过监听Listener的原始指针事件（仅4输出）
        HitTestBlocker(child: tapChild(3, 200)),
        HitTestBlocker(child: tapChild(4, 200)),

      ],
    );
  }

  Widget wChild(int index, double size) {
    return Listener(
      onPointerDown: (e) => print(index),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey,
      ),
    );
  }

  Widget tapChild(int index, double size) {
    return InkWell(
      onTap: () => print(index),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey,
      ),
    );
  }


}

class _WaterMarkTest extends StatelessWidget {
  const _WaterMarkTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Optimize: Listener只能处理层与层之间原始事件监听，针对同层（兄弟节点的hitTest）还是无能为力
        wChild(1, Colors.grey, 200, false),

        ///IgnorePointer的原理是`欺上瞒下`,对children的hitTestchildren返回false,
        ///对自身的hitTestSelf也返回false,这样自身组件上报的hitTest就是false[理解成谦虚礼让的组件]
        ///
        /// 这样就算其他待遍历的组件(eg 上面的wChild),不加任何修饰也能收到hitTest测试
        IgnorePointer(
          child: WaterMark(
            painter: TextWaterMarkPainter(text: 'wendux', rotate: -20),
          ),
        ),
      ],
    );
  }

  Widget wChild(int index, color, double size, [bool isListener = true]) {
    final container = Container(
      width: size,
      height: size,
      color: Colors.grey,
    );
    return isListener
        ? Listener(
            onPointerDown: (e) => print('$isListener Listener $index'),
            child: container,
          )
        : InkWell(
            child: container,
            onTap: () => print('$isListener InkWell $index'),
          );
  }
}

class StickerTest extends StatelessWidget {
  const StickerTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        wChild(1, Colors.blue, 200),
        HitTestBlocker(child: wChild(2, Colors.red, 100)),
      ],
    );
  }

  Widget wChild(int index, color, double size) {
    ///改为InkWell就不会有打印事件了，仅改为Listener才能监听到原始的
    return Listener(
      onPointerDown: (e)=> print('$index'),
      child: Container(
        width: size,
        height: size,
        color: color,
      ),
    );
  }
}

class GestureHitTestBlockerTest extends StatelessWidget {
  const GestureHitTestBlockerTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HitTestBlocker(child: wChild(1, 200)),
        HitTestBlocker(child: wChild(2, 200)),
      ],
    );
  }

  Widget wChild(int index, double size) {
    ///内部改为GestureDetector就只有2打印了(虽然外面包裹了HitTestBlocker,兄弟们都有机会hitTest)
    ///虽然两个wChild组件都通过了命中测试,但是GestureDetector会在事件分发阶段决定是否响应事件(非命中测试阶段)
    ///GestureDetector内部使用的GestureRecognizer，会在事件分发阶段决定是否消费（响应）事件，其他参与者（竞争失败者）同时也将收到事件被消费的消息
    return GestureDetector(
      onTap: () => print('$index'),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey,
      ),
    );
  }
}
