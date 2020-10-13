import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/preference_manager.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/utility/notifier.dart';
import 'package:plastic/widgets/account/register_page.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LogInPageState();
}

class LogInPageState extends State<LogInPage> {
  String _email = '';
  String _password = '';
  String _error = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> logInPressed() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState.validate()) return;

    try {
      var response = await Api.account.login(context, _email, _password);
      if (!response.successful) {
        Notifier.notify(
          context,
          message: response.message,
          color: Motif.negative,
        );
        return;
      }
      SharedPreferences preferences = PreferenceManager().get();
      await preferences.reload();
      preferences.setString("token", response.token);
      preferences.setString("email", response.user.email);
      preferences.setString("name", response.user.name);
      preferences.setString("id", response.user.id);

      Navigator.popUntil(context, ModalRoute.withName('home'));
      Navigator.pushReplacementNamed(context, 'home');
    } on HttpException catch (e) {
      setState(() {
        _error = e.message;
      });
    } on ApiException catch (e) {
      Notifier.handleApiError(context, e);
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "plastic",
                      style: Motif.titleStyle(Sizes.Title, Motif.title),
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
                      style: Motif.contentStyle(Sizes.Content, Motif.black),
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
                      controller: passwordController,
                      obscureText: true,
                      autocorrect: false,
                      onFieldSubmitted: (value) => logInPressed(),
                      enableSuggestions: true,
                      style: Motif.contentStyle(Sizes.Content, Motif.black),
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
                        return value != null && value.length != 0
                            ? null
                            : "Please enter your password.";
                      },
                    ),
                  ),
                  BorderButton(
                    color: Motif.title,
                    onPressed: () => logInPressed(),
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
                          style: Motif.contentStyle(Sizes.Label, Motif.black),
                        ),
                      ),
                      Expanded(
                        child: BorderButton(
                          color: Motif.neutral,
                          content: "register",
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage())),
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
