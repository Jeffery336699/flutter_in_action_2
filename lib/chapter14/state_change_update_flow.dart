import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class StateChangeTest extends StatefulWidget {
  const StateChangeTest({Key? key}) : super(key: key);

  @override
  _StateChangeTestState createState() => _StateChangeTestState();
}

class _StateChangeTestState extends State<StateChangeTest> {
  int index = 0;

  void update(VoidCallback fn) {
    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    /// persistentCallbacks:这是处理持久回调的阶段，是帧生成的重要部分。
    /// 例如，Flutter 会调用渲染树的 build 和 layout 方法来准备 UI。
    print('initState中 update 此时 $schedulerPhase'); // SchedulerPhase.persistentCallbacks阶段

    // Optimize: idle是调用 setState的最佳时机,在此时调用 setState，Flutter 会在下一帧中处理状态变化，很安全。
    // Optimize: postFrameCallbacks状态 也是一个不错的时机，因为此时帧已经绘制完成，可以在下一帧中处理状态变化。
    if (schedulerPhase == SchedulerPhase.idle ||
        schedulerPhase == SchedulerPhase.postFrameCallbacks) {
      setState(fn);
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(fn);
      });
    }
  }

  StreamSubscription<int>? _subscription;
  final Stream<int> _stream = Stream.periodic(Duration(seconds: 3), (count) => count).take(3);

  @override
  void initState() {
    super.initState();
    update(() {
      ///update 此时 SchedulerPhase.postFrameCallbacks，整个function函数都是在这个阶段，因为它被外部调度者（类似Android的编舞者）post到这个阶段才执行
      print('update 此时 ${SchedulerBinding.instance.schedulerPhase}'); //SchedulerPhase.postFrameCallbacks
      ++index;
    });
    ///SchedulerPhase.persistentCallbacks，就算在initState中此时也是帧的主阶段
    print('initState,SchedulerPhase: ${SchedulerBinding.instance.schedulerPhase}');

    // _subscription = _stream.listen((data) {
    // todo SchedulerPhase.idle空闲阶段,目前没有任何帧正在调度(个人理解是你有新的页面需要刷新，你请求次调度来刷新，你没有or静止，我当然不给你刷新呀)
    //   print('Data received: $data，SchedulerPhase: ${SchedulerBinding.instance.schedulerPhase}');
    // });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Optimize: 此时的build会执行两次，因为额外添加了一个在当前帧结束时的回调，该回调中setState会再次调用build方法刷新一次
    print('build......$index');

    /// 下面代码不会报错，因为在build时当前组件的dirty为true,而setState中
    /// 会先判断当前dirty值，如果为true会直接返回
    // setState(() {
    //   ++index;
    // });
    // return Text('$index');

    // todo build阶段不能调用setState,为setState就会走到build,那不无限循环了吗
    // return LayoutBuilder(
    //   builder: (context, c) {
    //     //SchedulerPhase.persistentCallbacks
    //     print(SchedulerBinding.instance.schedulerPhase);
    //     setState(() {
    //       ++index;
    //     });
    //     return const Text('xx');
    //   },
    // );

    /// todo 个人觉得在build方法里还是谨慎使用setState，因为setState会触发build方法，
    /// todo 如果在build方法里调用setState，会导致无限循环；可以移到initState中调用
    return LayoutBuilder(
      builder: (context, c) {
        //SchedulerPhase.persistentCallbacks，主要的build和layout方法都在这个阶段
        // print('LayoutBuilder-->${SchedulerBinding.instance.schedulerPhase}');
        return Text('xx-$index');
      },
    );
  }
}
