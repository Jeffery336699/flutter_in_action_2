import 'package:flutter/material.dart';

import '../widgets/index.dart';

class TurnBoxRoute extends StatefulWidget {
  const TurnBoxRoute({Key? key}) : super(key: key);

  @override
  _TurnBoxRouteState createState() => _TurnBoxRouteState();
}

class _TurnBoxRouteState extends State<TurnBoxRoute> {
  double _turns = .0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Optimize: 内部封装了RotationTransition, 但是每次setState都会重新build,
          // Optimize: 会导致内部组件的didUpdateWidget被调用(处理动画的逻辑)
          TurnBox(
            key: const ValueKey("1"),
            turns: _turns,
            speed: 500,
            child: const Icon(
              Icons.refresh,
              size: 50,
            ),
          ),
          TurnBox(
            key: const ValueKey("2"),
            turns: _turns,
            speed: 1000,
            child: const Icon(
              Icons.refresh,
              size: 150.0,
            ),
          ),
          ElevatedButton(
            child: const Text("顺时针旋转1/5圈"),
            onPressed: () {
              setState(() {
                _turns += .2;
              });
            },
          ),
          ElevatedButton(
            child: const Text("逆时针旋转1/5圈"),
            onPressed: () {
              setState(() {
                _turns -= .2;
              });
            },
          )
        ],
      ),
    );
  }
}
