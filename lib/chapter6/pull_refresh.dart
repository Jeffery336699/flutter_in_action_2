import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PullRefreshTestRoute extends StatelessWidget {
  const PullRefreshTestRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // buildSliverList(1, Colors.deepOrange),
        CupertinoSliverRefreshControl(
          builder: builder,
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
              (_, int index) => ListTile(
                    title: Text('$index'),
                  ),
              childCount: 50),
        )
      ],
    );
  }

  Widget builder(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent, //下拉距离
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    print('pulledExtent=$pulledExtent , refreshState=$refreshState');
    Widget widget;
    double width = min(25, pulledExtent); //这里还给出一个刷新指示器的由小变大的效果
    if (refreshState == RefreshIndicatorMode.refresh) {
      //组件被认为是刷新状态时(内部),我们发起刷新数据操作----仅仅一次事件
      widget = SizedBox(
        child: const CircularProgressIndicator(strokeWidth: 2),
        width: width,
        height: width,
      );
    } else {
      //RefreshIndicatorMode.drag:往下拉没松手(同时也包括没到距离的回弹回去);...还有诸多状态
      widget = Transform.rotate(
        angle: pulledExtent / 80 * 6.28,
        child: const CircularProgressIndicator(
          value: .85,
          strokeWidth: 2,
        ),
      );
    }
    return Center(
      child: SizedBox(
        width: width,
        height: width,
        child: Padding(padding: const EdgeInsets.all(2.0), child: widget),
      ),
    );
  }
}
