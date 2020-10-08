import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/utility/notifier.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
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
      var response =
          await Api.account.register(context, _email, _password, _name);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("token", response.token);
      preferences.setString("email", response.user.email);
      preferences.setString("name", response.user.name);
      Navigator.popUntil(context, ModalRoute.withName('home'));
    } on HttpException catch (e) {
      setState(() {
        _error = e.message;
      });
    } on ApiException catch (e) {
      Notifier.handleApiError(context, e);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Motif.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      style: Motif.contentStyle(Sizes.Header, Motif.title),
                    ),
                  ),
                  Container(
                    height: 105,
                    child: TextFormField(
                      controller: nameController,
                      autocorrect: false,
                      style: Motif.contentStyle(Sizes.Content, Motif.black),
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      enableSuggestions: true,
                      decoration: InputDecoration(
                        fillColor: Motif.lightBackground,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Constants.borderRadius),
                        ),
                        filled: true,
                        errorStyle: Motif.contentStyle(
                            Sizes.Notification, Motif.negative),
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
                      style: Motif.contentStyle(Sizes.Content, Motif.black),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      enableSuggestions: true,
                      decoration: InputDecoration(
                        fillColor: Motif.lightBackground,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Constants.borderRadius),
                        ),
                        filled: true,
                        errorStyle: Motif.contentStyle(
                            Sizes.Notification, Motif.negative),
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
                      style: Motif.contentStyle(Sizes.Content, Motif.black),
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      enableSuggestions: true,
                      decoration: InputDecoration(
                        fillColor: Motif.lightBackground,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Constants.borderRadius),
                        ),
                        filled: true,
                        errorStyle: Motif.contentStyle(
                            Sizes.Notification, Motif.negative),
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
                      style: Motif.contentStyle(Sizes.Content, Motif.black),
                      onFieldSubmitted: (value) => registerPressed(context),
                      enableSuggestions: true,
                      decoration: InputDecoration(
                        fillColor: Motif.lightBackground,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Constants.borderRadius),
                        ),
                        filled: true,
                        errorStyle: Motif.contentStyle(
                            Sizes.Notification, Motif.negative),
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
                          color: Motif.neutral,
                          onPressed: () => registerPressed(context),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      _error,
                      style: Motif.contentStyle(Sizes.Content, Motif.negative),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
