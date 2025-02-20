import 'package:flutter/material.dart';

class InheritedWidgetTestRoute extends StatefulWidget {
  const InheritedWidgetTestRoute({Key? key}) : super(key: key);

  @override
  _InheritedWidgetTestRouteState createState() =>
      _InheritedWidgetTestRouteState();
}

class _InheritedWidgetTestRouteState extends State<InheritedWidgetTestRoute> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      // Optimize:  直接使用InheritedWidget并没有太多使用性,还得结合观察者模式自己去搞一套(见第二个示例)
      child: ShareDataWidget(
        //使用ShareDataWidget
        data: count,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: _TestWidget(), //子widget中依赖ShareDataWidget
            ),
            Builder(builder: (context) {
              print("ElevatedButton build");
              return ElevatedButton(
                child: const Text("Increment"),
                //每点击一次，将count自增，然后重新build,ShareDataWidget的data将被更新
                onPressed: () {
                  // Optimize: 反正不能这样写,因为这样写会导致整个全部重构,应该向下面这样整个通知订阅机制(flutter就是得处处都得自己写)
                  // setState(() {
                  //   ++count;
                  // });

                  var widget = context
                      .getElementForInheritedWidgetOfExactType<
                          ShareDataWidget>()
                      ?.widget as ShareDataWidget;
                  widget.data++;
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ShareDataWidget extends InheritedWidget {
  ShareDataWidget({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  int data; //需要在子树中共享的数据，保存点击次数

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static ShareDataWidget? of(BuildContext context) {
    ///flutter                  I  Dependencies change
    /// flutter                  I  Dependencies change
    /// flutter                  I  Dependencies change
    /// flutter                  I  Dependencies change
    // return context.dependOnInheritedWidgetOfExactType<ShareDataWidget>();

    ///todo flutter                  I  Dependencies change
    ///todo 仅仅初始化的时候才会回调didChangeDependencies方法,后续点击build都不会被调用
    return context
        .getElementForInheritedWidgetOfExactType<ShareDataWidget>()
        ?.widget as ShareDataWidget;
  }

  //该回调决定当data发生变化时，是否通知子树中依赖data的Widget
  @override
  bool updateShouldNotify(ShareDataWidget old) {
    return old.data != data;
  }
}

class _TestWidget extends StatefulWidget {
  @override
  __TestWidgetState createState() => __TestWidgetState();
}

class __TestWidgetState extends State<_TestWidget> {
  @override
  Widget build(BuildContext context) {
    print('_TestWidget(StatefulWidget) build');

    ///使用InheritedWidget中的共享数据
    return Text(ShareDataWidget.of(context)!.data.toString());
    // return Text('常量');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //父或祖先widget中的InheritedWidget改变(updateShouldNotify返回true)时会被调用。
    //如果build中没有并非dependOnInheritedWidgetOfExactType形式的依赖InheritedWidget，则此回调不会被调用。
    print("Dependencies change");
  }
}
