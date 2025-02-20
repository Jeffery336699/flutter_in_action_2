import 'package:flutter/widgets.dart';

class LayoutLogPrint<T> extends StatelessWidget {
  const LayoutLogPrint({
    Key? key,
    this.tag,
    this.debugPrint = print,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final Function(Object? object) debugPrint;
  final T? tag;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      assert(() {
        double screenWidth = MediaQuery.of(context).size.width;
        // debugPrint('screenWidth: $screenWidth'); // 夜深模拟器450
        debugPrint('${tag ?? key ?? child.runtimeType}: $constraints');
        return true;
      }());
      return child;
    });
  }
}
