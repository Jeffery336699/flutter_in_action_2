import 'package:flutter/material.dart';

import '../common.dart';

class SliverFlexibleHeaderRoute extends StatefulWidget {
  const SliverFlexibleHeaderRoute({Key? key}) : super(key: key);

  @override
  State<SliverFlexibleHeaderRoute> createState() =>
      _SliverFlexibleHeaderRouteState();
}

class _SliverFlexibleHeaderRouteState extends State<SliverFlexibleHeaderRoute> {
  double _initHeight = 250;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        ///这里面封装了很多逻辑,有点复杂(到时学完layout之后再来看看)
        ///目前封装暴露出来的还是挺好用的
        SliverFlexibleHeader(
          visibleExtent: _initHeight,
          builder: (context, availableHeight, direction) {
            print('build--->');
            return GestureDetector(
              onTap: () => print('tap'),
              child: LayoutBuilder(builder: (context, cons) {
                return Image(
                  image: const AssetImage("imgs/avatar.png"),
                  width: 50.0,
                  height: availableHeight,
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.cover,
                );
              }),
            );
          },
        ),
        SliverToBoxAdapter(
          child: ListTile(
            onTap: () {
              setState(() {
                _initHeight = _initHeight == 250 ? 150 : 250;
              });
            },
            title: const Text('重置高度'),
            trailing: Text('当前高度 $_initHeight'),
          ),
        ),
        buildSliverList(30),
      ],
    );
  }
}
