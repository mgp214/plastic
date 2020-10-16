import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/view/view_frame_card.dart';

class EditViewPage extends StatefulWidget {
  final View view;

  const EditViewPage({Key key, this.view}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditViewPageState();
}

class EditViewPageState extends State<EditViewPage> {
  Widget _getAddFrame(Color background) => Card(
        color: background,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.add,
            color: Motif.title,
            size: Constants.iconSize,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => WillPopScope(
        child: Scaffold(
          backgroundColor: Motif.background,
          body: Stack(
            children: [
              ViewFrameCard(
                frame: widget.view.root,
                rebuildLayout: () => setState(() {}),
              ),
              Positioned(
                bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
                right: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Draggable(
                      feedback: _getAddFrame(Colors.transparent),
                      child: _getAddFrame(Motif.background),
                      data: null as dynamic,
                      onDragCompleted: () => setState(() {}),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        onWillPop: () {
          return Future.value(true);
        },
      );
}
