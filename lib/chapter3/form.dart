import 'package:flutter/material.dart';

class FormTestRoute extends StatefulWidget {
  const FormTestRoute({Key? key}) : super(key: key);

  @override
  _FormTestRouteState createState() => _FormTestRouteState();
}

class _FormTestRouteState extends State<FormTestRoute> {
  final TextEditingController _unameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final GlobalKey _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, //todo 设置globalKey，用于后面获取FormState
      // `autovalidateMode` 用于控制 `Form` 表单中各个 `FormField` (例如 `TextFormField`) 的自动校验时机。
      //
      // `AutovalidateMode.onUserInteraction` 的意思是，**在用户与输入框进行交互后**开始自动校验。
      //
      // ### 详细说明
      //
      // `AutovalidateMode` 有以下几个枚举值：
      //
      // 1.  `disabled`: (默认值) 不会自动校验。只有当手动调用 `_formKey.currentState.validate()` 时才会校验，就像你代码中点击“登录”按钮时做的那样。
      // 2.  `always`: 总是自动校验。只要 `Widget` 重建 (`build`) 就会触发校验，这通常会导致用户还没开始输入，界面上就显示了错误提示（例如“用户名不能为空”），用户体验不佳。
      // 3.  `onUserInteraction`: 在用户首次与 `FormField` 交互后，会持续自动校验。例如，用户点击了输入框，输入了一些内容，然后移开焦点或继续输入，此时就会触发校验。
      //
      // ### 使用场景和举例
      //
      // `AutovalidateMode.onUserInteraction` 是最常用的模式，因为它提供了即时反馈，同时又避免了在用户输入前就显示错误。
      //
      // **在你的代码中的具体表现：**
      //
      // 1.  当应用启动时，用户名和密码框下方不会有任何错误提示。
      // 2.  当用户点击“用户名”输入框，输入一个字符，然后再删除它，使其变为空。此时因为用户已经“交互”过了，`validator` 会被触发，输入框下方会立刻显示错误信息：“用户名不能为空”。
      // 3.  同样，当用户在“密码”框中输入了 "123"（少于6位），输入框下方会立刻显示：“密码不能少于6位”。
      // 4.  如果用户输入了符合校验规则的内容，错误提示就会自动消失。
      //
      // 这种方式可以实时地引导用户正确地填写表单，提升了用户体验。
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: _unameController,
            decoration: const InputDecoration(
              labelText: "用户名",
              hintText: "用户名或邮箱",
              icon: Icon(Icons.person),
            ),
            // Optimize: 校验用户名,返回null表示验证ok
            validator: (v) {
              return v!.trim().isNotEmpty ? null : "用户名不能为空";
            },
          ),
          TextFormField(
            controller: _pwdController,
            decoration: const InputDecoration(
              labelText: "密码",
              hintText: "您的登录密码",
              icon: Icon(Icons.lock),
            ),
            obscureText: true,
            //校验密码
            validator: (v) {
              return v!.trim().length > 5 ? null : "密码不能少于6位";
            },
          ),
          // 登录按钮
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("登录"),
                    ),
                    onPressed: () {
                      // 通过_formKey.currentState 获取FormState后，
                      // 调用validate()方法校验用户名密码是否合法，校验
                      // 通过后再提交数据。
                      // todo 相当于收拢(集线器),校验Form下all FormField是否都校验通过
                      if ((_formKey.currentState as FormState).validate()) {
                        //验证通过提交数据
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('验证通过提交数据'),
                        ));
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
