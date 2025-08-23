import 'package:flutter/material.dart';

class SizeConstraintsRoute extends StatelessWidget {
  const SizeConstraintsRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget whiteBox = const DecoratedBox(
      decoration: BoxDecoration(color: Colors.white),
    );
    Widget redBox = const DecoratedBox(
      decoration: BoxDecoration(color: Colors.red),
    );
    Widget greenBox = const DecoratedBox(
      decoration: BoxDecoration(color: Colors.green),
    );
    Widget blueBox = const DecoratedBox(
      decoration: BoxDecoration(color: Colors.blue),
    );
    Widget purpleBox = const DecoratedBox(
      decoration: BoxDecoration(color: Colors.purple),
    );
    Widget amberBox = const DecoratedBox(
      decoration: BoxDecoration(color: Colors.amber),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("约束"),
        actions: <Widget>[
          Container(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              value: .7,
              valueColor: AlwaysStoppedAnimation(Colors.green),
            ),
            decoration: const BoxDecoration(color: Colors.white),
          ),
          const SizedBox(
            width: 10,
          ),
          const UnconstrainedBox(
            child: SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                value: .9,
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          // Center(
          //   child:
          const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              value: .7,
              valueColor: AlwaysStoppedAnimation(Colors.red),
            ),
          ),
          // ),
          const SizedBox(
            width: 10,
          ),
          const CircularProgressIndicator(
            strokeWidth: 3,
            value: .9,
            valueColor: AlwaysStoppedAnimation(Colors.green),
          ),
          const SizedBox(
            width: 10,
          ),
          ConstrainedBox(
            constraints: BoxConstraints.tight(const Size.square(100)),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              value: .9,
              valueColor: AlwaysStoppedAnimation(Colors.purple),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /// tht first优先级:子类的大小,以父类对子类的约束为主
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: double.infinity, //宽度尽可能大
                minHeight: 50.0, //最小高度为50像素
              ),
              child: SizedBox(height: 5.0, child: redBox),
            ),
            SizedBox(width: 80.0, height: 80.0, child: greenBox),

            /// 多重约束取交集,这样才能满足各方需求
            ConstrainedBox(
              constraints:
                  const BoxConstraints(minWidth: 60.0, minHeight: 60.0),
              //父
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minWidth: 90.0, minHeight: 20.0),
                //子
                child: blueBox,
              ),
            ),
            ConstrainedBox(
              constraints:
                  const BoxConstraints(minWidth: 90.0, minHeight: 20.0),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minWidth: 60.0, minHeight: 60.0),
                child: purpleBox,
              ),
            ),

            ///不约束子组件的大小,组件多大就多大
            ///`UnconstrainedBox` 会移除其父组件（在这里是 `Column`）对子组件的约束。
            ///
            /// 通常情况下，`Column` 会给它的子组件施加一个有限的宽度约束（通常是屏幕宽度）。`Text` 组件在接收到有限的宽度约束时会自动换行。
            ///
            /// 然而，由于您将 `Text` 放置在了 `UnconstrainedBox` 中，`UnconstrainedBox` 传递给其子组件的宽度约束是无限的。
            /// 因此，`Text` 组件认为它有无限的空间来水平布局，所以它不会自动换行，而是在一行上继续渲染，这通常会导致像素溢出（overflow）。
            ///
            /// 简单来说，`UnconstrainedBox` “告诉” `Text` 组件：“你可以随心所欲地变宽”，所以 `Text` 就不会换行了。
            UnconstrainedBox(
              alignment: Alignment.topLeft,
              //     `clipBehavior: Clip.hardEdge` 这个属性定义了当子组件的内容超出其父组件边界时如何进行裁剪。
              //
              // 在这里，它用在 `UnconstrainedBox` 上：
              //
              // 1.  `UnconstrainedBox` 允许其子组件（`Padding` -> `Wrap` -> `Text`）按其期望的尺寸渲染，
              //      这可能导致子组件比 `UnconstrainedBox` 本身要大。
              // 2.  `Clip.hardEdge` 意味着如果子组件的尺寸超出了 `UnconstrainedBox` 的边界，超出的部分将被直接裁剪掉，
              //      并且裁剪的边缘不会进行抗锯齿处理。这是一种性能较高的裁剪方式。
              //
              // 简单来说，它确保了溢出的内容不会被绘制到组件的边界之外。
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  children: [
                    Text(
                      '张三丰的徒弟' * 30,
                      maxLines: 3,
                    )
                  ],
                ),
              ),
            ),

            AspectRatio(
              aspectRatio: 3, //宽是高的三倍
              child: amberBox,
            )
          ]
              .map((e) => Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: e,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _onPressPrint() {
    print('打印看看');
  }
}
