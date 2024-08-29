import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/routes.dart';

class FixedExtentList extends StatelessWidget {
  const FixedExtentList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // itemExtent: 56,
      // prototypeItem: const ListTile(title: Text("1")),
      itemBuilder: (context, index) {
        ///1.上述啥都不加的情况,0: BoxConstraints(w=450.0, 0.0<=h<=Infinity)
        ///2.上述解开[itemExtent: 56]的情况: 0: BoxConstraints(w=450.0, h=56.0)
        ///3.述解开[prototypeItem: const ListTile(title: Text("1"))]的情况同2,注意最终以实际`prototypeItem`的值为主
        return LayoutLogPrint(
          tag: index,
          child: ListTile(title: Text("$index")),
        );
      },
    );
  }
}
