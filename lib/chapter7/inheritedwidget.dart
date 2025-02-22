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
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      print('内部 setState');
                      ++count;
                    });
                  },
                  child: const Text('Increment'),
                );
              },
            ),
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

  // Optimize: 并非这里的数据变化就会触发整个页面重组，而是你还需要弄个一套LivaData通知系统，监听这个值变化时对应使用到这个值的部分widget触发重组
  // Optimize: 例如现成的ChangeNotifier、ValueListenableBuilder、StreamBuilder、FutureBuilder等，从而衍生出不同的状态框架
  int data; //需要在子树中共享的数据，保存点击次数

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static ShareDataWidget? of(BuildContext context,{bool dependOn = true}) {
     if(dependOn) {
       /// flutter                  I  Dependencies change
       /// flutter                  I  Dependencies change
       /// flutter                  I  Dependencies change
       /// flutter                  I  Dependencies change
       return context.dependOnInheritedWidgetOfExactType<ShareDataWidget>();
     } else {
       /// flutter                  I  Dependencies change
       /// 仅仅初始化的时候才会回调didChangeDependencies方法,后续点击build都不会被调用
       return context
        .getElementForInheritedWidgetOfExactType<ShareDataWidget>()
        ?.widget as ShareDataWidget;
     }
  }

  //该回调决定当data发生变化时，是否通知子树中依赖data的Widget
  @override
  bool updateShouldNotify(ShareDataWidget old) {
    return /*old.data != data*/true;
  }
}

class _TestWidget extends StatefulWidget {
  @override
  __TestWidgetState createState() => __TestWidgetState();
}

class __TestWidgetState extends State<_TestWidget> {
  @override
  void initState() {
    super.initState();
    // Optimize: 就算InheritedWidget组件内被监听的数据有所改变（纯数据非LiveData类型），仍然需要其组件来触发重组后，
    // Optimize: 依赖这个数据的子组件调用才会收到最新的状态（数据），PS：个人感觉不加封装用起来太难用了
    Stream.periodic(const Duration(seconds: 5), (int x) => x).listen((event) {
      print('Stream.periodic $event,[${ShareDataWidget.of(context,dependOn: false)!.data.toString()}]');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('_TestWidget(StatefulWidget) build');

    ///使用InheritedWidget中的共享数据
    return Text(ShareDataWidget.of(context)!.data.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //父或祖先widget中的InheritedWidget改变(updateShouldNotify返回true)时会被调用。
    //如果build中没有并非dependOnInheritedWidgetOfExactType形式的依赖InheritedWidget，则此回调不会被调用。
    print("Dependencies change");
  }
}
