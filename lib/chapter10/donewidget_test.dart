import 'package:flutter/material.dart';

import 'done_widget.dart';

class DoneWidgetTestRoute extends StatefulWidget {
  const DoneWidgetTestRoute({Key? key}) : super(key: key);

  @override
  State<DoneWidgetTestRoute> createState() => _DoneWidgetTestRouteState();
}

class _DoneWidgetTestRouteState extends State<DoneWidgetTestRoute> {
  bool show = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          show = !show;
        });
      },
      child: Center(
        child: Column(
          children: <Widget>[
            Visibility(
              visible: show,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DoneWidget(outline: true),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("操作成功"),
                  ),
                  DoneWidget(),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DoneWidget(outline: true, show: show),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("操作成功-2"),
                ),
                DoneWidget(show: show),
              ],
            )
          ],
        ),
      ),
    );
  }
}
