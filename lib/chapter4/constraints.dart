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
            UnconstrainedBox(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [Text('xx' * 30)]),
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
