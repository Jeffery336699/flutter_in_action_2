import 'package:flutter/material.dart' hide Page;

import '../common.dart';

class TabViewRoute extends StatelessWidget {
  const TabViewRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage(children: [
      Page('TabBarView', const TabViewRoute1(), withScaffold: false),
      Page('DefaultTabController', const TabViewRoute2(), withScaffold: false),
    ]);
  }
}

class TabViewRoute1 extends StatefulWidget {
  const TabViewRoute1({Key? key}) : super(key: key);

  @override
  _TabViewRoute1State createState() => _TabViewRoute1State();
}

class _TabViewRoute1State extends State<TabViewRoute1>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List tabs = ["新闻", "历史", "图片"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Name"),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((e) => Tab(text: e)).toList(),
        ),
      ),

      ///TabBarView封装了PageView,你就把它当做PageView使用吧
      ///这里演示KeepAliveWrapper的强大,状态的保留是否应用(通过keepAlive)
      ///
      ///原理:借助还是系统C/S模型的AutomaticKeepAlive状态保留机制,
      ///子类想改变是否缓存状态就向AutomaticKeepAlive发送一个通知(KeepAliveNotification),S端收到通知就去更改keepAlive的状态
      body: TabBarView(
        //构建
        controller: _tabController,
        children: tabs.map((e) {
          return KeepAliveWrapper(
            ///包裹个方便查看页面是否重建的log组件
            child: LayoutLogPrint(
              child: Container(
                alignment: Alignment.center,
                child: Text(e, textScaleFactor: 5),
              ),
              tag: e,
            ),
            keepAlive: false,
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    // 释放资源
    _tabController.dispose();
    super.dispose();
  }
}

class TabViewRoute2 extends StatelessWidget {
  const TabViewRoute2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List tabs = ["新闻", "历史", "图片"];

    ///借助TabBar和TabBarView在tabController没有设置的情况下,会从组件树向上查找的特性,统一设置它们公共一个DefaultTabController(方便联动)
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("App Name"),
          bottom: TabBar(
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),
        ),
        body: TabBarView(
          //构建
          children: tabs.map((e) {
            return KeepAliveWrapper(
              child: LayoutLogPrint(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(e, textScaleFactor: 5),
                ),
                tag: e,
              ),
              keepAlive: true,
            );
          }).toList(),
        ),
      ),
    );
  }
}
