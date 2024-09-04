import 'package:flutter/material.dart';

///可以借助AnimatedBuilder封装动画,外部只需要传递animation+child,
///内部就帮你把动画效果构建出来了(你可以根据不同需求构建不同的动画架子,eg 如下是一个大小变化的动画)
class GrowTransition extends StatelessWidget {
  const GrowTransition({
    Key? key,
    required this.animation,
    this.child,
  }) : super(key: key);

  final Widget? child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, child) {
          return SizedBox(
            height: animation.value,
            width: animation.value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}

class GrowTransitionRoute extends StatefulWidget {
  const GrowTransitionRoute({Key? key}) : super(key: key);

  @override
  _GrowTransitionRouteState createState() => _GrowTransitionRouteState();
}

//需要继承TickerProvider，如果有多个AnimationController，则应该使用TickerProviderStateMixin。
class _GrowTransitionRouteState extends State<GrowTransitionRoute>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween(begin: 0.0, end: 300.0).animate(controller);
    //记得initState中得启动动画
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GrowTransition(
      child: /*Image.asset("imgs/avatar.png")*/
          const ColoredBox(color: Colors.green),
      animation: animation,
    );
  }

  @override
  dispose() {
    //路由销毁时需要释放动画资源
    controller.dispose();
    super.dispose();
  }
}
