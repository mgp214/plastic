import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/api/backend_service.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/account/register_widget.dart';
import 'package:plastic/widgets/components/border_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LogInState();
}

class LogInState extends State<LogInWidget> {
  String _email = '';
  String _password = '';
  String _error = '';
  bool _autoValidate = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> logInPressed(context) async {
    FocusScope.of(context).unfocus();
    _autoValidate = true;
    if (!_formKey.currentState.validate()) return;

    try {
      var response = await BackendService.login(_email, _password);
      if (!response.successful) {
        Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            title: 'oops',
            message: response.message,
            duration: Duration(seconds: 3))
          ..show(context);
        return;
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("token", response.token);
      preferences.setString("email", response.user.email);
      preferences.setString("name", response.user.name);
      preferences.setString("id", response.user.id);
      Navigator.popUntil(context, ModalRoute.withName('home'));
    } on HttpException catch (e) {
      setState(() {
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: Container(
        color: Style.background,
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            autovalidate: _autoValidate,
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "plastic",
                    style: Style.getStyle(FontRole.Title, Style.primary),
                  ),
                ),
                Container(
                  height: 105,
                  child: TextFormField(
                    controller: emailController,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                    },
                    enableSuggestions: true,
                    style: Style.getStyle(FontRole.Content, Style.accent),
                    decoration: InputDecoration(
                      fillColor: Style.inputField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Style.borderRadius),
                      ),
                      filled: true,
                      errorStyle: Style.getStyle(FontRole.Tooltip, Style.error),
                      hintText: "email",
                    ),
                    onChanged: (value) => setState(() {
                      _email = value.trim();
                      _error = '';
                    }),
                    validator: (value) {
                      return EmailValidator.validate(value)
                          ? null
                          : "Please enter a valid email address.";
                    },
                  ),
                ),
                Container(
                  height: 105,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    autocorrect: false,
                    onFieldSubmitted: (value) => logInPressed(context),
                    enableSuggestions: true,
                    style: Style.getStyle(FontRole.Content, Style.accent),
                    decoration: InputDecoration(
                      fillColor: Style.inputField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Style.borderRadius),
                      ),
                      filled: true,
                      errorStyle: Style.getStyle(FontRole.Tooltip, Style.error),
                      hintText: "password",
                    ),
                    onChanged: (value) => setState(() {
                      _error = '';
                      _password = value;
                    }),
                    validator: (value) {
                      return value != null && value.length != 0
                          ? null
                          : "Please enter your password.";
                    },
                  ),
                ),
                BorderButton(
                  color: Style.primary,
                  onPressed: () => logInPressed(context),
                  content: "hello",
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10, left: 10),
                      child: Text(
                        "new here? why not ",
                        style: Style.getStyle(
                          FontRole.Display3,
                          Style.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: BorderButton(
                        color: Style.accent,
                        content: "register",
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterWidget())),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    _error,
                    style: Style.getStyle(
                      FontRole.Display3,
                      Style.error,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
