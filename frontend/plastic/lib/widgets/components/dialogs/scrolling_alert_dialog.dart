import 'package:flutter/material.dart';
import 'package:plastic/utility/style.dart';

class ScrollingAlertDialog extends StatelessWidget {
  final String header;
  final Color headerColor;
  final Color okColor;
  final List<Widget> children;

  const ScrollingAlertDialog({
    Key key,
    this.header,
    @required this.children,
    @required this.headerColor,
    @required this.okColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Style.background,
        title: header == null
            ? null
            : Text(header,
                style: Style.getStyle(FontRole.Display3, headerColor)),
        content: SingleChildScrollView(
          child: Container(
            height: 200,
            width: double.maxFinite,
            child: ListView(children: children),
          ),
        ),
        actions: [
          FlatButton(
            child: Text(
              "Okay",
              style: Style.getStyle(
                FontRole.Display3,
                okColor,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
}
