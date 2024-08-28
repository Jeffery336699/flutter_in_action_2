import 'package:flutter/material.dart';
import 'package:flutter_in_action_2/ext.dart';

class CenterColumnRoute extends StatelessWidget {
  const CenterColumnRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text("hi"),
        Text(" world"),
        Text(
          "Jeffery 是天才",
          style: TextStyle(fontSize: 32),
        ),
      ],
    ).withBorder();
  }
}
