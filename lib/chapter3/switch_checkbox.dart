import 'package:flutter/material.dart';

class SwitchAndCheckBoxRoute extends StatefulWidget {
  const SwitchAndCheckBoxRoute({Key? key}) : super(key: key);

  @override
  _SwitchAndCheckBoxRouteState createState() => _SwitchAndCheckBoxRouteState();
}

class _SwitchAndCheckBoxRouteState extends State<SwitchAndCheckBoxRoute> {
  bool _switchSelected = true; //维护单选开关状态
  bool _checkboxSelected = true; //维护复选框状态
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            ///这个Switch的切换是ok的,它引起了状态的变化与刷新
            Switch(
              value: _switchSelected, //当前状态
              onChanged: (value) {
                //重新构建页面
                setState(() {
                  _switchSelected = value;
                });
              },
            ),
            const Text("关"),

            ///数据_switchSelected驱动UI,这个Switch的UI操作切换改变但是没有改变_switchSelected的话,最终呈现还是原样
            Switch(
              value: !_switchSelected, //当前状态
              onChanged: (value) {},
            ),
            const Text("开"),
          ],
        ),
        Row(
          children: <Widget>[
            Checkbox(
              value: _checkboxSelected,
              activeColor: Colors.red, //选中时的颜色
              onChanged: (value) {
                setState(() {
                  print('Checkbox:$value');
                  _checkboxSelected = value!;
                });
              },
            ),
            const Text("未选中"),
            Checkbox(
              value: !_checkboxSelected,
              activeColor: Colors.red, //选中时的颜色
              onChanged: (value) {},
            ),
            const Text("选中"),
          ],
        )
      ],
    );
  }
}
