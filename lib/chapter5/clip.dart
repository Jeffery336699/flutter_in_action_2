import 'package:flutter/material.dart';

class ClipRoute extends StatelessWidget {
  const ClipRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 头像
    Image avatar = Image.asset("imgs/avatar.png", width: 60.0);
    print('${avatar.width} , ${avatar.height}'); // 60.0 , null
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        avatar, //不剪裁
        ClipOval(child: avatar), //剪裁为圆形
        ClipRRect(
          //剪裁为圆角矩形
          borderRadius: BorderRadius.circular(5.0),
          child: avatar,
        ),
        ClipPath(
          child: avatar,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,

              ///宽度设为原来宽度一半，另一半会溢出,但会显示(目的:演示默认情况下,没有裁剪的状况)
              widthFactor: .5,
              child: avatar,
            ),
            const Text(
              "你好世界",
              style: TextStyle(color: Colors.green),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRect(
              ///同上对比,将溢出部分剪裁
              child: Align(
                alignment: Alignment.topLeft,
                widthFactor: .5, //宽度设为原来宽度一半
                child: avatar,
              ),
            ),
            const Text("你好世界", style: TextStyle(color: Colors.green))
          ],
        ),
        DecoratedBox(
          decoration: const BoxDecoration(color: Colors.red),
          child: ClipRect(
            clipper: MyClipper(), //使用自定义的clipper
            child: avatar,
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(color: Colors.red),
          child: MyClipRect(
            child: avatar,
          ),
        )
      ],
    );
  }
}

///演示自定义裁剪,确定对目标的裁剪区域
class MyClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => const Rect.fromLTWH(10.0, 10.0, 40.0, 30.0);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}

class MyClipRect extends StatelessWidget {
  const MyClipRect({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var rect = const Rect.fromLTWH(10.0, 10.0, 40.0, 30.0);

    ///todo 这里我的理解是子组件先把他设置为不穷大,然后填充到SizedBox中,最后把多余部分裁剪掉?? 还是有些不懂
    return ClipRect(
      child: SizedBox(
        width: rect.width,
        height: rect.height,
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: child,
        ),
      ),
    );
  }
}
