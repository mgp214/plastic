import 'package:flutter/material.dart';
import 'package:plastic/widgets/log_in_widget.dart';
import 'package:plastic/widgets/view_widget.dart';

import 'model/user.dart';

void main() {
  runApp(PlasticApp());
}

class PlasticApp extends StatelessWidget {
  // This widget is the root of your application.
  User user;

  @override
  Widget build(BuildContext context) {
    Widget home = user == null ? LogInWidget() : ViewWidget();

    return MaterialApp(
      title: 'plastic',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Material(
        child: home,
      ),
    );
  }
}
