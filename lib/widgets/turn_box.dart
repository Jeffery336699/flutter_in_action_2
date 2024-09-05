import 'package:flutter/widgets.dart';

/// Animates the rotation of a widget when [turns]  is changed.

class TurnBox extends StatefulWidget {
  const TurnBox({
    Key? key,
    this.turns = .0,
    this.speed = 200,
    required this.child,
  }) : super(key: key);

  /// Controls the rotation of the child.
  ///
  /// If the current value of the turns is v, the child will be
  /// rotated v * 2 * pi radians before being painted.
  final double turns;

  /// Animation duration in milliseconds
  final int speed;

  final Widget child;

  @override
  _TurnBoxState createState() => _TurnBoxState();
}

class _TurnBoxState extends State<TurnBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: -double.infinity,
      upperBound: double.infinity,
    );
    _controller.value = widget.turns;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///build方法当然只被调用一次,但是内部的_controller.value是一直在变化的
    ///并且由于lowerBound/upperBound设置成正负无穷,所以value的变化是不受[0,1]的限制的,转一圈还是1的步长
    print('${widget.key} build=======>>>>>>');
    _controller.addListener(() {
      print('${widget.key} -- ${_controller.value}');
    });
    return RotationTransition(
      turns: _controller,
      child: widget.child,
    );
  }

  @override
  void didUpdateWidget(TurnBox oldWidget) {
    print('${widget.key} --> didUpdateWidget');
    super.didUpdateWidget(oldWidget);
    if (oldWidget.turns != widget.turns) {
      ///发现组件的状态有改变,就动画到新的目的值
      _controller.animateTo(
        widget.turns,
        duration: Duration(milliseconds: widget.speed),
        curve: Curves.easeOut,
      );
    }
  }
}
