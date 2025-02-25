import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_in_action_2/ext.dart';

class LeftRightBox extends MultiChildRenderObjectWidget {
  const LeftRightBox({
    Key? key,
    required List<Widget> children,
  })  : assert(children.length == 2, "只能传两个children"),
        super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLeftRight();
  }
}

class LeftRightParentData extends ContainerBoxParentData<RenderBox> {}

class RenderLeftRight extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, LeftRightParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, LeftRightParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! LeftRightParentData) {
      child.parentData = LeftRightParentData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    RenderBox leftChild = firstChild!;
    LeftRightParentData leftChildParentData =
        leftChild.parentData! as LeftRightParentData;
    // childParentData.nextSibling!指的是当前节点的下一个兄弟节点。
    RenderBox rightChild = leftChildParentData.nextSibling!;

    // 当前的环境实在容器中，此时布局的是右孩子，需要结合我（拥有双孩子的容器）的上层父容器的约束条件来调整给到右孩子的约束，
    // 我们限制右孩子宽度不超过总宽度一半，只有布局完成才能获取它右孩子的大小size
    rightChild.layout(
      constraints.copyWith(maxWidth: constraints.maxWidth / 2),
      parentUsesSize: true,
    );

    //调整右子节点的offset
    LeftRightParentData rightChildParentData = rightChild.parentData! as LeftRightParentData;
    rightChildParentData.offset = Offset(
      constraints.maxWidth - rightChild.size.width,
      0,
    );

    print(constraints.maxWidth - rightChild.size.width);

    // layout left child
    // 左子节点的offset默认为（0，0），为了确保左子节点始终能显示，我们不修改它
    leftChild.layout(
      //左侧剩余的最大宽度
      constraints.copyWith(
        maxWidth: constraints.maxWidth - rightChild.size.width,
      ),
      parentUsesSize: true,
    );

    // 判断左右孩子的高度，在布局时进行垂直偏移，传递到parentData中（这里增加个居中显示的功能）
    // Optimize: 我天，GitHubCopilot真是太强了，写个中文注释直接给我写代码了！！
    if (leftChild.size.height > rightChild.size.height) {
      rightChildParentData.offset = Offset(
        rightChildParentData.offset.dx,
        (leftChild.size.height - rightChild.size.height) / 2,
      );
    } else {
      leftChildParentData.offset = Offset(
        leftChildParentData.offset.dx,
        (rightChild.size.height - leftChild.size.height) / 2,
      );
    }

    //在所有孩子布局完毕后，最终确定容器（此拥有双孩子的容器）的size
    size = Size(
      constraints.maxWidth,
      max(leftChild.size.height, rightChild.size.height),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class LeftRightBoxTestRoute extends StatelessWidget {
  const LeftRightBoxTestRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LeftRightBox(children: [
      const Text("国漫精选").withBorder(),
      GestureDetector(onTap: () => print("点击更多"), child:  Text("更多》", style: TextStyle(fontSize: 32)))
          .withBorder(color: Colors.red),
    ]).withBorder(color: Colors.yellow);
  }
}
