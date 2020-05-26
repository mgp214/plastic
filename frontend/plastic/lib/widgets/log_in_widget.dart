import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/api/backend_service.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/register_widget.dart';
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
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("token", response.token);
      preferences.setString("email", response.user.email);
      preferences.setString("name", response.user.name);
      Navigator.pop(context);
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
                  height: 100,
                  child: TextFormField(
                    controller: emailController,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                    },
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      fillColor: Style.inputField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      filled: true,
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
                  height: 100,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    autocorrect: false,
                    onFieldSubmitted: (value) => logInPressed(context),
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      fillColor: Style.inputField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      filled: true,
                      hintText: "password",
                    ),
                    onChanged: (value) => setState(() {
                      _error = '';
                      _password = value;
                    }),
                    validator: (value) {
                      return value != null
                          ? null
                          : "Please enter your password.";
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: OutlineButton(
                        borderSide: BorderSide(
                            color: Style.primary,
                            width: 2,
                            style: BorderStyle.solid),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "hello",
                          style: Style.getStyle(
                            FontRole.Display3,
                            Style.primary,
                          ),
                        ),
                        onPressed: () => logInPressed(context),
                        color: Style.accent,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
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
                        child: Padding(
                          padding: EdgeInsets.only(top: 5, left: 10),
                          child: OutlineButton(
                            borderSide: BorderSide(
                                color: Style.accent,
                                width: 2,
                                style: BorderStyle.solid),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            padding: EdgeInsets.all(15),
                            child: Text(
                              "register",
                              style: Style.getStyle(
                                FontRole.Display3,
                                Style.accent,
                              ),
                            ),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterWidget())),
                            color: Style.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
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
