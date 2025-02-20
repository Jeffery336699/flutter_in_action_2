import 'package:flutter/material.dart' hide Page;

import '../common.dart';

class PersistentHeaderRoute extends StatelessWidget {
  const PersistentHeaderRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage(children: [
      Page('SliverPersistentHeader示例1', wSample1(), padding: false),
      Page('SliverPersistentHeader示例2', wSample2(context), withScaffold: false),
    ]);
  }

  Widget wSample1() {
    ///1. 系统的SliverPersistentHeader时,第一个SliverPersistentHeaderDelegate的overlapsContent有问题,永远都是false(就算有重叠)
    ///   但是之后的没问题(eg,从第二个开始)
    ///2. 无论maxExtent和minExtent相等or不相等时,当滚动触发到组件SliverPersistentHeader收缩时,shrinkOffset的值都是从0到达maxExtent,
    ///   头部组件的也会在maxExtent与minExtent不同时发生UI变化
    ///3. 详情可以看这个示例的日志输出
    return CustomScrollView(
      slivers: [
        buildSliverList(),

        ///注意:在使用SliverPersistentHeader时使用的都是pinned:true,也就是固定到顶部
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate(
            maxHeight: 80,
            minHeight: 50,
            child: buildHeader(1),
          ),
        ),
        buildSliverList(),
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate.fixedHeight(
            height: 50,
            child: buildHeader(2),
          ),
        ),
        buildSliverList(20),
      ],
    );
  }

  Widget wSample2(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: ColoredBox(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              ///floating:true就是随便滑动出去多远,一往下滑动就能出来
              SliverPersistentHeader(
                floating: false, // 是否往下立马出来. true:无论滚动多远立马出来;false:滚动到顶部才出来
                delegate: SliverHeaderDelegate.fixedHeight(
                  height: 50,
                  child: const TextField(),
                ),
              ),
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: const SliverAppBar(
                  title: Text('示例二'),
                  pinned: true,
                  collapsedHeight: 56,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverHeaderDelegate.fixedHeight(
                  height: 50,
                  child: buildHeader(2),
                ),
              ),
              buildSliverList(30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(int i) {
    return GestureDetector(
      key: ValueKey(i),
      onTap: () => print('header $i'),
      child: Container(
        color: Colors.lightBlue.shade200,
        alignment: Alignment.centerLeft,
        child: Text("PersistentHeader $i"),
      ),
    );
  }
}
