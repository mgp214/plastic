import 'package:flutter/material.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/home_widget.dart';

void main() {
  runApp(PlasticApp());
}

class PlasticApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'plastic',
      theme: ThemeData(
        primaryColor: Style.primary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeWidget(),
    );
  }
}
