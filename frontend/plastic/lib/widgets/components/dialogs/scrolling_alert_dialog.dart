import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';

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
        backgroundColor: Motif.lightBackground,
        title: header == null
            ? null
            : Text(header, style: Motif.headerStyle(Sizes.Header, headerColor)),
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
              style: Motif.actionStyle(Sizes.Action, okColor),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
}
