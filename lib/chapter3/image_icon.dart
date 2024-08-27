import 'package:flutter/material.dart';

class ImageAndIconRoute extends StatelessWidget {
  const ImageAndIconRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var img = const AssetImage("imgs/avatar.png");
    return SingleChildScrollView(
      child: Column(
          children: <Image>[
        ///设置诸多image的宽高大小,最终以何种形式'填充'(fit)到父组件中
        Image(
          image: img,
          height: 50.0,
          width: 100.0,
          fit: BoxFit.fill,
        ),
        Image(
          image: img,
          height: 50,
          width: 50.0,
          fit: BoxFit.contain,
        ),
        Image(
          image: img,
          width: 100.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
        Image(
          image: img,
          width: 100.0,
          height: 50.0,
          fit: BoxFit.fitWidth,
        ),
        Image(
          image: img,
          width: 100.0,
          height: 50.0,
          fit: BoxFit.fitHeight,
        ),
        Image(
          image: img,
          width: 100.0,
          height: 50.0,
          fit: BoxFit.scaleDown,
        ),
        Image(
          image: img,
          height: 50.0,
          width: 100.0,
          fit: BoxFit.none,
        ),

        ///此时在没写height的情况下,根据fit枚举类型,自适应出height来呈现
        Image(
          image: img,
          width: 100.0,
          color: Colors.blue,
          colorBlendMode: BlendMode.difference,
          fit: BoxFit.fill,
        ),
        Image(
          image: img,
          width: 100.0,
          height: 200.0,
          repeat: ImageRepeat.repeatY,
        )
      ].map((e) {
        return Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue, // 边框颜色
                  width: 1.0, // 边框宽度
                  style: BorderStyle.solid, // 边框样式
                ),
              ),
              child: SizedBox(
                width: 100,
                child: e,
              ),
            ),
            Text(e.fit.toString())
          ],
        );
      }).toList()),
    );
  }
}

class IconFontsRoute extends StatelessWidget {
  const IconFontsRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text(
          ///对应就是Icons.fingerprint的codePoint(图标字体下的唯一标识,16进制)
          '\uE287' * 20,
          style: const TextStyle(
            ///必须是Icons工具类的图标字体哟,否则无法识别上面'\uE287'数据
            fontFamily: "MaterialIcons",
            fontSize: 24.0,
            color: Colors.green,
          ),
        ),
        showIcons(),
      ],
    );
  }

  Widget showIcons() {
    String icons = "";
    // accessible: 0xe03e
    icons += "\uE03e";
    // error:  0xe237
    icons += " \uE237";
    // fingerprint: 0xe287
    icons += " \uE287";

    return Text(
      icons,
      style: const TextStyle(
        fontFamily: "MaterialIcons",
        fontSize: 24.0,
        color: Colors.green,
      ),
    );
  }
}
