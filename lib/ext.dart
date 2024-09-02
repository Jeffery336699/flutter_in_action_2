import 'package:flutter/material.dart';

///给任意组件拓展一个边框
extension BorderExtension on Widget {
  Container withBorder(
      {Color color = Colors.blue,
      double width = 1.0,
      BorderStyle style = BorderStyle.solid,
      Color? bgColor}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
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
