import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EventConflictTest extends StatelessWidget {
  const EventConflictTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///默认GestureDetector嵌套,点击到子组件时,此例子onTapUp两个GestureDetector会竞争事件,
    ///但最终仅仅只有子组件响应(默认是子组件优先)
    // return GestureDetector(
    //   onTapUp: (x) => print("2"),
    //   behavior: HitTestBehavior.opaque,
    //   child: Container(
    //     width: 200,
    //     height: 200,
    //     color: Colors.blue,
    //     alignment: Alignment.center,
    //     child: GestureDetector(
    //       onTapUp: (x) => print("1"),
    //       child: Container(
    //         width: 50,
    //         height: 50,
    //         color: Colors.grey,
    //       ),
    //     ),
    //   ),
    // );
    ///解决手势冲突方式一:通过Listener解决手势冲突 ----  2,1都会输出
    ///因为竞争只是针对手势的,而Listener用于监听的是原始事件,并非语义上的手势,根本不会遵守手势竞争的逻辑
    // return Listener(
    //   onPointerUp: (x) => print("2"),
    //   child: Container(
    //     width: 200,
    //     height: 200,
    //     color: Colors.red,
    //     alignment: Alignment.center,
    //     child: GestureDetector(
    //       onTap: () => print("1"),
    //       child: Container(
    //         width: 50,
    //         height: 50,
    //         color: Colors.grey,
    //       ),
    //     ),
    //   ),
    // );
    ///解决方法二:自定义Recognizer解决手势冲突-----1,2都会打印
    ///自定义GestureRecognizer,在其rejectGesture方法中强制调用acceptGesture方法(我太想成功了~)
    return customGestureDetector(
      onTap: () => print("2"),
      child: Container(
        width: 200,
        height: 200,
        color: Colors.green,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => print("1"),
          child: Container(
            width: 50,
            height: 50,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

RawGestureDetector customGestureDetector({
  GestureTapCallback? onTap,
  GestureTapDownCallback? onTapDown,
  Widget? child,
}) {
  return RawGestureDetector(
    child: child,
    gestures: {
      CustomTapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<CustomTapGestureRecognizer>(
        () => CustomTapGestureRecognizer(),
        (detector) {
          detector.onTap = onTap;
          detector.onTapDown = onTapDown;
        },
      )
    },
  );
}

///简单继承个点击的手势识别器
class CustomTapGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    //不，我不要失败，我要成功
    //super.rejectGesture(pointer);
    //宣布成功
    super.acceptGesture(pointer);
  }
}
