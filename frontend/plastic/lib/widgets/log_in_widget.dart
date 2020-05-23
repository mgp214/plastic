import 'package:flutter/material.dart';
import 'package:plastic/utility/plastic_colors.dart';

class LogInWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LogInState();
}

class LogInState extends State<LogInWidget> {
  String _email;
  String _password;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void emailChanged(String value) {
    setState(() {
      _email = value;
      emailController.text = _email;
    });
  }

  void passwordChanged(String value) {
    setState(() {
      _password = value;
      passwordController.text = _password;
    });
  }

  void logInPressed() {}

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: PlasticColors.background,
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                "plastic",
                style:
                    PlasticColors.getStyle(FontRole.Title, FontColor.Primary),
              ),
            ),
            TextField(
              controller: emailController,
              autocorrect: false,
              enableSuggestions: true,
              decoration: InputDecoration(
                fillColor: PlasticColors.inputField,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                filled: true,
                hintText: "email",
              ),
              onChanged: emailChanged,
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: true,
              decoration: InputDecoration(
                fillColor: PlasticColors.inputField,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                filled: true,
                hintText: "password",
              ),
              onChanged: passwordChanged,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "hello",
                        style: PlasticColors.getStyle(
                          FontRole.Display3,
                          FontColor.White,
                        ),
                      ),
                      onPressed: logInPressed,
                      color: PlasticColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "or...",
                style: PlasticColors.getStyle(
                  FontRole.Content,
                  FontColor.White,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "register",
                        style: PlasticColors.getStyle(
                          FontRole.Display3,
                          FontColor.Black,
                        ),
                      ),
                      onPressed: logInPressed,
                      color: PlasticColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
