import 'package:flutter/material.dart';

class AnimatedSwitcherCounterRoute extends StatefulWidget {
  const AnimatedSwitcherCounterRoute({Key? key}) : super(key: key);

  @override
  _AnimatedSwitcherCounterRouteState createState() =>
      _AnimatedSwitcherCounterRouteState();
}

class _AnimatedSwitcherCounterRouteState
    extends State<AnimatedSwitcherCounterRoute> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              /**
               *  todo 这样不精准,因为动画是一个持续的过程
               *  flutter                  I  animation.value:1.0
                  flutter                  I  animation.value:0.0
               */
              print('animation.value:${animation.value}');
              /**
               *  flutter                  I  animation.addListener:0.95858
                  flutter                  I  animation.addListener:0.95858
                  flutter                  I  animation.addListener:0.04142
                  flutter                  I  animation.addListener:0.8758225
                  flutter                  I  animation.addListener:0.8758225
                  flutter                  I  animation.addListener:0.1241775
                  flutter                  I  animation.addListener:0.79295
                  flutter                  I  animation.addListener:0.79295
                  flutter                  I  animation.addListener:0.20705
                  flutter                  I  animation.addListener:0.7100575
                  flutter                  I  animation.addListener:0.7100575
                  flutter                  I  animation.addListener:0.2899425
                  flutter                  I  animation.addListener:0.6271500000000001
                  flutter                  I  animation.addListener:0.6271500000000001
                  flutter                  I  animation.addListener:0.37284999999999996
                  flutter                  I  animation.addListener:0.544255
                  flutter                  I  animation.addListener:0.544255
                  flutter                  I  animation.addListener:0.45574499999999996
                  flutter                  I  animation.addListener:0.46135000000000004
                  flutter                  I  animation.addListener:0.46135000000000004
                  flutter                  I  animation.addListener:0.53865
                  flutter                  I  animation.addListener:0.33709250000000013
                  flutter                  I  animation.addListener:0.33709250000000013
                  flutter                  I  animation.addListener:0.6629074999999999
                  flutter                  I  animation.addListener:0.1309300000000001
                  flutter                  I  animation.addListener:0.1309300000000001
                  flutter                  I  animation.addListener:0.8690699999999999
                  flutter                  I  animation.addListener:0.006477500000000025
                  flutter                  I  animation.addListener:0.006477500000000025
                  flutter                  I  animation.addListener:0.9935225
                  flutter                  I  animation.addListener:0.0
                  flutter                  I  animation.addListener:0.0
                  flutter                  I  animation.addListener:1.0
               */
              animation.addListener(() {
                print('animation.addListener:${animation.value}');
              });
              return ScaleTransition(child: child, scale: animation);
            },
            child: Text(
              '$_count',

              ///显示指定key，不同的key会被认为是不同的Text，这样才能执行动画
              key: ValueKey<int>(_count),
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          ElevatedButton(
            child: const Text(
              '+1',
            ),
            onPressed: () {
              setState(() {
                _count += 1;
              });
            },
          ),
        ],
      ),
    );
  }
}
