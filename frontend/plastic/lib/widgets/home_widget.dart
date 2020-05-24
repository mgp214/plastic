import 'package:flutter/material.dart';
import 'package:plastic/api/backend_service.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/log_in_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomeWidget> {
  User _loggedInUser;
  String _token;
  bool _isDoneCheckingPrefs = false;

  void _goToLogin() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => LogInWidget()))
        .then((value) => getPrefs());
  }

  Future<Null> getPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey("token")) {
      _goToLogin();
      return;
    }
    var token = preferences.getString("token");
    var name = preferences.getString("name");
    var email = preferences.getString("email");
    var isTokenValid = await BackendService.checkToken(token);

    if (!isTokenValid) {
      preferences.remove("token");
      preferences.remove("name");
      preferences.remove("email");
      _goToLogin();
      return;
    }

    setState(() {
      _isDoneCheckingPrefs = true;
      _token = token;
      _loggedInUser = User(name: name, email: email);
    });
  }

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDoneCheckingPrefs)
      return Container(
          color: Style.background,
          alignment: Alignment.center,
          child: CircularProgressIndicator());
    return Material(
      child: Container(
        color: Style.background,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Hello ${_loggedInUser.name},",
              style: Style.getStyle(FontRole.Display3, Style.primary),
            ),
            Text(
              "This is where you'll find your stuff.",
              style: Style.getStyle(FontRole.Display3, Style.primary),
            ),
          ],
        ),
      ),
    );
  }
}
