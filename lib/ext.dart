import 'package:flutter/material.dart';

///给任意组件拓展一个边框
extension BorderExtension on Widget {
  Container withBorder(
      {Color color = Colors.blue,
      double width = 1.0,
      BorderStyle style = BorderStyle.solid}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: width,
          style: style,
        ),
      ),
      child: this,
    );
  }
}
