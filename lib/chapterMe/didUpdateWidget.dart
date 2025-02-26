import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  final int counter;

  const CounterWidget({Key? key, required this.counter}) : super(key: key);

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  /// 1. didUpdateWidget往往是父类的重新构建时调用，比如父类的setState方法被调用时，子类的didUpdateWidget方法会被调用。
  ///    child需要满足runtime与key都相等时才会调用didUpdateWidget方法,相当于做值的比较
  /// 2. didUpdateWidget方法中可以比较新旧widget的一些属性，比如上面的例子中比较了counter属性
  /// 3. didUpdateWidget方法中可以获取到旧的widget，通过oldWidget参数，然后可以通过oldWidget.counter获取到旧的counter属性。
  ///
  ///   CounterWidget build 0
  ///   点击后[此时父有状态组件仅单单调用setState方法]
  ///   didUpdateWidget[false] , 0 --> 0
  ///   CounterWidget build 0
  @override
  void didUpdateWidget(covariant CounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget[${oldWidget.counter != widget.counter}] , ${oldWidget.counter} --> ${widget.counter}');
    if (oldWidget.counter != widget.counter) {

    }
  }

  @override
  Widget build(BuildContext context) {
    print('【$hashCode】CounterWidget build ${widget.counter}');
    return ElevatedButton(
        onPressed: () {
          // Optimize: 直接调用setState仅仅会调用到build方法，不会调用到didUpdateWidget方法
          setState(() {
            // print('Counter: ${widget.counter}');
          });
        },
        child: Text('Counter: ${widget.counter}'));
  }
}

class DidUpdateWidget extends StatefulWidget {
  const DidUpdateWidget({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<DidUpdateWidget> {
  final int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('didUpdateWidget Example'),
        ),
        body: Center(
          child: CounterWidget(counter: _counter),
        ),
        floatingActionButton: IconButton(
          icon: const CircleAvatar(
            child: Icon(Icons.add),
          ),
          onPressed: _incrementCounter,
        ),
      ),
    );
  }
}
