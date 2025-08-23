import 'package:flutter/material.dart';

class ContainerRoute extends StatelessWidget {
  const ContainerRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50.0, left: 120.0),
      constraints:
          const BoxConstraints.tightFor(width: 200.0, height: 150.0), //卡片大小
      decoration: const BoxDecoration(
        //背景装饰
        gradient: RadialGradient(
          //背景径向渐变
          colors: [Colors.red, Colors.orange],
          center: Alignment.topLeft,
        //   `radius` 属性用于设置径向渐变的半径。
        //
        // 它的值是渐变中心（由 `center` 属性定义）到容器最远角的距离的一个分数。
        //
        // *   默认值为 `1.0`，表示渐变的圆形边缘会触及容器最远的角落。
        // *   值小于 `1.0`（如此处的 `.98`）会使渐变范围收缩，看起来更小。
        // *   值大于 `1.0` 会使渐变范围超出容器边界。
        //
        // **常见使用场景：**
        //
        //   此属性通常用于精细控制径向渐变的外观，例如创建一个聚光灯效果，或者调整渐变色散开的大小和速度。
          radius: .98,
        ),
        boxShadow: [
          //卡片阴影
          BoxShadow(
            color: Colors.black54,
            offset: Offset(2.0, 2.0),
            blurRadius: 4.0,
          )
        ],
      ),
      transform: Matrix4.rotationZ(.2), //卡片倾斜变换
      alignment: Alignment.center, //卡片内文字居中
      child: const Text(
        //卡片文字
        "5.20", style: TextStyle(color: Colors.white, fontSize: 40.0),
      ),
    );
  }
}
