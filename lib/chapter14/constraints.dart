import 'package:flutter/material.dart';

class ConstraintsTest extends StatelessWidget {
  const ConstraintsTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var container = Container(width: 200, height: 200, color: Colors.red);
    // return UnconstrainedBox(
    //   child: container,
    // );
    // return Align(
    //   child: container,
    //   alignment: Alignment.bottomCenter,
    // );
    return Container(
      color: Colors.green,
    );
  }
}
