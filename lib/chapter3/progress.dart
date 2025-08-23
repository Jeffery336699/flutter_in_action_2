import 'package:flutter/material.dart';

class ProgressRoute extends StatefulWidget {
  const ProgressRoute({Key? key}) : super(key: key);

  @override
  _ProgressRouteState createState() => _ProgressRouteState();
}

class _ProgressRouteState extends State<ProgressRoute>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _animationController.forward();
    _animationController.addListener(() => setState(() => {}));

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///todo 点击actionbar上的打印按钮,触发重新刷新看看效果
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
            value: .5,
          ),

          /// 借助外部的约束类组件(eg SizedBox)来控制child(进度组件)的大小
          /// 其内部使用的RenderObject为`RenderConstrainedBox createRenderObject`
          SizedBox(
            height: 30,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
              value: .5,
            ),
          ),
          SizedBox(
            height: 100,
            width: 130,
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
              value: .7,
            ),
          ),
          CircularProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
            value: .5,
          ),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: ColorTween(begin: Colors.grey, end: Colors.blue)
                .animate(_animationController),
            value: _animationController.value,
          ),
          CircularProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: ColorTween(begin: Colors.grey, end: Colors.blue)
                .animate(_animationController),
            value: _animationController.value,
          ),
          // 这个 `CircularProgressIndicator` 会一直转圈，是因为它的 `value` 属性没有被设置。
          //
          // 当 `CircularProgressIndicator` 的 `value` 属性为 `null` 时，它会显示一个不确定的进度指示器，表现为持续的旋转动画，用来表示一个正在进行但进度未知的操作。
          //
          // 在您的代码中，其他的进度条，例如第 77-82 行的 `CircularProgressIndicator`，设置了 `value: _animationController.value`，
          // 所以它会根据动画控制器的值来显示一个从 0% 到 100% 的确切进度。而您选择的这个组件（第 83-87 行）没有设置 `value`，因此它会一直显示为不确定状态的旋转动画。
          CircularProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: ColorTween(begin: Colors.grey, end: Colors.blue)
                .animate(_animationController),
          )
        ].map((e) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: e,
          );
        }).toList(),
      ),
    );
  }
}
