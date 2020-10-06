import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/widgets/components/input/border_button.dart';

class SettingsPage extends StatefulWidget {
  final User user;

  SettingsPage({@required this.user});

  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  void logout() {
    Api.account.logout(context).then((value) => Navigator.pop(context));
  }

  void logoutAll() {
    Api.account.logoutAll(context).then((value) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Motif.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            child: ListView(
              children: <Widget>[
                Text("Settings",
                    style: Motif.contentStyle(Sizes.Header, Motif.title)),
                Divider(
                  color: Motif.black,
                  thickness: 1.5,
                  height: 8,
                  endIndent: 30,
                ),
                Divider(
                  color: Motif.black,
                  thickness: 1.5,
                  height: 8,
                ),
                Text(
                  "This is where you'll find all the wonderful settings you can adjust.",
                  style: Motif.contentStyle(Sizes.Content, Motif.black),
                ),
                Divider(
                  color: Motif.black,
                  thickness: 1.5,
                  height: 8,
                ),
                BorderButton(
                  color: Motif.neutral,
                  content: "log out on this device",
                  onPressed: logout,
                ),
                BorderButton(
                  color: Motif.negative,
                  content: "log out on ALL devices",
                  onPressed: logoutAll,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
