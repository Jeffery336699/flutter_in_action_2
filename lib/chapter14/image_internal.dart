import 'dart:math';

import 'package:flutter/material.dart';

class ImageInternalTestRoute extends StatelessWidget {
  const ImageInternalTestRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MyImage(
          imageProvider: const NetworkImage(
            "https://book.flutterchina.club/logo.png",
          ),
          number: Random().nextInt(10000),
        ),
      ],
    );
  }
}

class MyImage extends StatefulWidget {
  const MyImage({
    Key? key,
    required this.imageProvider,
    required this.number,
  }) : super(key: key);

  final ImageProvider imageProvider;
  final int number;

  @override
  _MyImageState createState() => _MyImageState();
}

class _MyImageState extends State<MyImage> {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  @override
  void didChangeDependencies() {
    print('1 -- didChangeDependencies');
    super.didChangeDependencies();
    // We call _getImage here because createLocalImageConfiguration() needs to
    // be called again if the dependencies changed, in case the changes relate
    // to the DefaultAssetBundle, MediaQuery, etc, which that method uses.
    _getImage();
  }

  @override
  void didUpdateWidget(MyImage oldWidget) {
    ///todo 当组件内容有更新时会回调此生命周期方法(第一次init时不会被调用),一般是前后两次内容有变化时(上面的random就是测试)
    ///记得闪电热重载一次就能看到该回调: didUpdateWidget: oldWidget.number=1355,widget.number=6397
    print(
        'didUpdateWidget: oldWidget.number=${oldWidget.number},widget.number=${widget.number}');
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) _getImage();
  }

  void _getImage() {
    var oldImageStream = _imageStream;
    _imageStream =
        widget.imageProvider.resolve(createLocalImageConfiguration(context));
    print(
        '_getImage-->${_imageStream!.key} , ${oldImageStream?.key} ; 不相等: ${_imageStream!.key != oldImageStream?.key}');
    if (_imageStream!.key != oldImageStream?.key) {
      // If the keys are the same, then we got the same image back, and so we don't
      // need to update the listeners. If the key changed, though, we must make sure
      // to switch our listeners to the  image stream.
      final ImageStreamListener listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream!.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      // Trigger a build whenever the image changes.
      _imageInfo = imageInfo;
    });
  }

  @override
  void dispose() {
    print('dispose');
    _imageStream!.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('2 -- build');
    return RawImage(
      image: _imageInfo?.image, // this is a dart:ui Image object
      scale: _imageInfo?.scale ?? 1.0,
    );
  }
}
