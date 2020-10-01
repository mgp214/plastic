import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/components/input/border_button.dart';

class SettingsWidget extends StatefulWidget {
  final User user;

  SettingsWidget({@required this.user});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<SettingsWidget> {
  void logout() {
    Api.account.logout().then((value) => Navigator.pop(context));
  }

  void logoutAll() {
    Api.account.logoutAll().then((value) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ListView(
            children: <Widget>[
              Text("Settings",
                  style: Style.getStyle(FontRole.Display2, Style.accent)),
              Divider(
                color: Style.accent,
                thickness: 1.5,
                height: 8,
                endIndent: 30,
              ),
              Divider(
                color: Style.accent,
                thickness: 1.5,
                height: 8,
              ),
              Text(
                "This is where you'll find all the wonderful settings you can adjust.",
                style: Style.getStyle(
                  FontRole.Content,
                  Style.white,
                ),
              ),
              Divider(
                color: Style.accent,
                thickness: 1.5,
                height: 8,
              ),
              BorderButton(
                color: Style.primary,
                content: "log out on this device",
                onPressed: logout,
              ),
              BorderButton(
                color: Style.error,
                content: "log out on ALL devices",
                onPressed: logoutAll,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
