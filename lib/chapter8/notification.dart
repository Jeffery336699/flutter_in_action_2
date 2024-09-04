import 'package:flutter/material.dart';

class NotificationRoute extends StatefulWidget {
  const NotificationRoute({Key? key}) : super(key: key);

  @override
  NotificationRouteState createState() {
    return NotificationRouteState();
  }
}

class NotificationRouteState extends State<NotificationRoute> {
  String _msg = "";
  final pageController = PageController();
  int count = 0;

  @override
  Widget build(BuildContext context) {
    //监听通知
    return NotificationListener<MyNotification>(
      onNotification: (notification) {
        print(notification.msg);
        return false;
      },
      child: NotificationListener<MyNotification>(
        onNotification: (notification) {
          setState(() {
            // _msg += notification.msg + "  ";
            _msg += notification.msg + "\n";
          });
          return false; //不拦截,继续往上冒泡
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
//           ElevatedButton(
//           onPressed: () => MyNotification("Hi").dispatch(context),
//           child: Text("Send Notification"),
//          ),
              Builder(
                ///借助Builder缩小context的范围
                builder: (context) {
                  return ElevatedButton(
                    ///按钮点击时分发通知
                    onPressed: () =>
                        MyNotification("Hi" * (++count)).dispatch(context),
                    child: const Text("Send Notification"),
                  );
                },
              ),
              Text(_msg)
            ],
          ),
        ),
      ),
    );
  }
}

///自定义通过
class MyNotification extends Notification {
  MyNotification(this.msg);

  final String msg;
}
