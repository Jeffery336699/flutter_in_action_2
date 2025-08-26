import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

///交织动画,在统一的controller下,组合多个动画,串行or并行 执行
class StaggerRoute extends StatefulWidget {
  const StaggerRoute({Key? key}) : super(key: key);

  @override
  _StaggerRouteState createState() => _StaggerRouteState();
}

class _StaggerRouteState extends State<StaggerRoute>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _playAnimation() async {
      // Optimize: orCancel 属性用于处理动画在执行过程中动画被取消的情况，orCancel 属性确保 await 语句不会抛出异常（返回null），从而使代码能够优雅地处理取消情况。
      // orCancel 是 TickerFuture 的一个 getter，它返回一个新的 Future。  _controller.forward() 和 _controller.reverse() 都返回一个 TickerFuture。
      // 当你 await 一个 TickerFuture 时，如果动画在完成前被取消（例如，因为 Widget 被销毁），它会抛出一个 TickerCanceled 异常。
      // 使用 orCancel 可以优雅地处理这种情况。await _controller.forward().orCancel 所等待的 Future 在动画被取消时会正常完成（值为 null），而不会抛出 TickerCanceled 异常。
      // 先正向执行动画
      await _controller.forward().orCancel;
      // 再反向执行动画
      await _controller.reverse().orCancel;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _playAnimation(),
            child: const Text("start animation"),
          ),
          Container(
            width: 300.0,
            height: 300.0,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              border: Border.all(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            //调用我们定义的交错动画Widget
            child: StaggerAnimation(controller: _controller),
          ),
        ],
      ),
    );
  }
}

class StaggerAnimation extends StatelessWidget {
  StaggerAnimation({
    Key? key,
    required this.controller,
  }) : super(key: key) {
    //高度动画; Tween这里估值器,确定起点~终点的任意类型参数
    height = Tween<double>(
      begin: .0,
      end: 300.0,
    ).animate(
      ///并入插值器曲线,并且只取0~0.6这段间隔
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.0, 0.6, //间隔，前60%的动画时间
          curve: Curves.ease,
        ),
      ),
    );

    color = ColorTween(
      begin: Colors.green,
      end: Colors.red,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.0, 0.6, //间隔，前60%的动画时间
          curve: Curves.ease,
        ),
      ),
    );

    padding = Tween<EdgeInsets>(
      begin: const EdgeInsets.only(left: .0),
      end: const EdgeInsets.only(left: 100.0),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.6, 1.0, //间隔，后40%的动画时间
          curve: Curves.ease,
        ),
      ),
    );
  }

  late final Animation<double> controller;
  late final Animation<double> height;
  late final Animation<EdgeInsets> padding;
  late final Animation<Color?> color;

  Widget _buildAnimation(BuildContext context, child) {
    return Container(
      alignment: Alignment.bottomLeft,
      padding:padding.value ,
      child: Container(
        color: color.value,
        width: 50.0,
        height: height.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ///AnimatedBuilder最终返回的是builder方法里构建出来的widget
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}
