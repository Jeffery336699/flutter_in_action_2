import 'package:flutter/material.dart' hide Page;
import 'package:flutter_in_action_2/ext.dart';

import '../common.dart';

class CustomScrollViewTestRoute extends StatelessWidget {
  const CustomScrollViewTestRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage(children: [
      Page('两个ListView', buildTwoListView()),
      Page('合并两个list', buildTwoSliverList()),
      Page('SliverAppBar', buildSliverAppBar(), withScaffold: false),
      Page('顶部是PageView', buildWithPageView()),
    ]);
  }

  Widget buildSliverAppBar() {
    ///因为本路由没有使用Scaffold，为了让子级Widget(如Text)使用
    ///Material Design 默认的样式风格,我们使用Material作为本路由的根。
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          //AppBar，包含一个导航栏
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Demo'),
              background: Image.asset(
                "./imgs/sea.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              //Grid
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //Grid按两列显示
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 4.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  //创建子widget
                  return Container(
                    alignment: Alignment.center,
                    color: Colors.cyan[100 * (index % 9)],
                    child: Text('grid item $index'),
                  );
                },
                childCount: 20,
              ),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                //创建列表项
                return Container(
                  alignment: Alignment.center,
                  color: Colors.lightBlue[100 * (index % 9)],
                  child: Text('list item $index'),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTwoListView() {
    var listView = ListView.builder(
      itemCount: 20,
      itemBuilder: (_, index) => ListTile(title: Text('$index')),
    );

    ///这种情况,各自滚动自己的,相互无影响
    return Column(
      children: [
        Expanded(child: listView),
        const Divider(color: Colors.grey),
        Expanded(child: listView),
      ],
    );
  }

  Widget buildTwoSliverList() {
    var listView = buildSliverList(10);

    ///CustomScrollView+Sliver系滚动组件(一般是实现按需加载eg.ListView)=可以一起联动组件
    return CustomScrollView(
      slivers: [
        listView,
        listView,
      ],
    );
  }

  Widget buildWithPageView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 300,

            ///当前PageView只处理水平滚动方向,而CustomScrollView处理垂直方向滚动,两者并不冲突
            child: PageView(
              children: [
                const Text("1").withBorder(),
                const Text("2").withBorder(color: Colors.red)
              ],
            ),
          ),
        ),
        buildSliverList(20),
      ],
    );
  }
}
