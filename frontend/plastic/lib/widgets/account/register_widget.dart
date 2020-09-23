import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/components/border_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new RegisterState();
}

class RegisterState extends State<RegisterWidget> {
  String _email = '';
  String _password = '';
  String _name = '';
  String _error = '';

  bool _autoValidate = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController password1Controller = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> registerPressed(context) async {
    FocusScope.of(context).unfocus();
    _autoValidate = true;
    if (!_formKey.currentState.validate()) return;

    try {
      var response = await Api.register(_email, _password, _name);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("token", response.token);
      preferences.setString("email", response.user.email);
      preferences.setString("name", response.user.name);
      Navigator.popUntil(context, ModalRoute.withName('home'));
    } on HttpException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
                    "register",
                    style: Style.getStyle(FontRole.Display1, Style.primary),
                  ),
                ),
                Container(
                  height: 105,
                  child: TextFormField(
                    controller: nameController,
                    autocorrect: false,
                    style: Style.getStyle(FontRole.Content, Style.accent),
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      fillColor: Style.inputField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Style.borderRadius),
                      ),
                      filled: true,
                      errorStyle: Style.getStyle(FontRole.Tooltip, Style.error),
                      hintText: "name",
                    ),
                    onChanged: (value) => setState(() {
                      _name = value.trim();
                      _error = '';
                    }),
                    validator: (value) {
                      return value != null && value.length != 0
                          ? null
                          : "Please enter a name (any name will do)";
                    },
                  ),
                ),
                Container(
                  height: 105,
                  child: TextFormField(
                    controller: emailController,
                    autocorrect: false,
                    style: Style.getStyle(FontRole.Content, Style.accent),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    enableSuggestions: true,
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
                    controller: password1Controller,
                    obscureText: true,
                    autocorrect: false,
                    style: Style.getStyle(FontRole.Content, Style.accent),
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    enableSuggestions: true,
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
                      if (value == null) {
                        return "Please enter a password.";
                      }
                      if (value.length < 7) {
                        return "Must be at least 7 characters.";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  height: 105,
                  child: TextFormField(
                    controller: password2Controller,
                    obscureText: true,
                    autocorrect: false,
                    style: Style.getStyle(FontRole.Content, Style.accent),
                    onFieldSubmitted: (value) => registerPressed(context),
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      fillColor: Style.inputField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Style.borderRadius),
                      ),
                      filled: true,
                      errorStyle: Style.getStyle(FontRole.Tooltip, Style.error),
                      hintText: "password, again",
                    ),
                    onChanged: (value) => setState(() {
                      _error = '';
                    }),
                    validator: (value) {
                      if (value == null || value.length == 0) {
                        return "Please enter your password.";
                      }
                      if (value != _password) {
                        return "Passwords don't match.";
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: BorderButton(
                        content: "sign me up",
                        color: Style.accent,
                        onPressed: () => registerPressed(context),
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
