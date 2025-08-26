import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({Key? key,
    this.colors,
    this.width,
    this.height,
    this.onPressed,
    this.borderRadius,
    required this.child,
  }) : super(key: key);

  // 渐变色数组
  final List<Color>? colors;

  // 按钮宽高
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  //点击回调
  final GestureTapCallback? onPressed;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    //确保colors数组不空
    List<Color> _colors =
        colors ?? [theme.primaryColor, theme.primaryColorDark];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _colors),
        borderRadius: borderRadius,
        //border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      child: Material(
      // `type: MaterialType.transparency` 属性的作用是使 `Material` 组件的背景变为透明。
      //
      // 在这个 `GradientButton` 组件中，它的作用至关重要：
      //
      // 1.  `InkWell` 组件（提供点击时的水波纹效果）需要一个 `Material` 组件作为其祖先才能正确绘制效果。
      // 2.  按钮的渐变背景是由父级 `DecoratedBox` 的 `gradient` 属性提供的。
      // 3.  如果 `Material` 组件不设置为透明，它会有一个默认的背景颜色（通常是白色或主题色），这会遮挡住 `DecoratedBox` 绘制的渐变背景。
      //
      // 因此，通过设置 `MaterialType.transparency`，`Material` 组件本身变得透明，使得底层的渐变背景能够显示出来，同时它仍然能为子组件 `InkWell` 提供绘制水波纹效果所需的功能。
      //
      // **常见使用场景：**
      //
      // 当您需要在一个非标准背景（如渐变、图片）上实现 Material Design 的水波纹点击效果时，通常会使用这种方式。
        type: MaterialType.transparency,
        child: InkWell(
          splashColor: _colors.last,
          highlightColor: Colors.transparent,
          borderRadius: borderRadius,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: height, width: width),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DefaultTextStyle(
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
