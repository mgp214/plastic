import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view.dart';

class EditViewPage extends StatefulWidget {
  final View view;

  const EditViewPage({Key key, this.view}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditViewPageState();
}

class EditViewPageState extends State<EditViewPage> {
  @override
  Widget build(BuildContext context) => WillPopScope(
        child: Scaffold(
            backgroundColor: Motif.background,
            body: Text("View editor!",
                style: Motif.contentStyle(Sizes.Content, Motif.black))),
        onWillPop: () {
          return Future.value(true);
        },
      );
}
