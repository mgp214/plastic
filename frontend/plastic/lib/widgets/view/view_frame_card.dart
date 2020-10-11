import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view_frame.dart';
import 'package:plastic/utility/constants.dart';

class ViewFrameCard extends StatefulWidget {
  final ViewFrame frame;

  const ViewFrameCard({Key key, @required this.frame}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ViewFrameCardState();

  // Widget build(BuildContext context) => Draggable(
  //       feedback: _getCard(),
  //       child: DragTarget(
  //         builder: (context, candidateData, rejectedData) => Container(
  //           constraints: BoxConstraints.expand(),
  //           alignment: Alignment.center,
  //           width: double.maxFinite,
  //           height: double.maxFinite,
  //           child: _getCard(),
  //         ),
  //       ),
  //     );
}

class ViewFrameCardState extends State<ViewFrameCard> {
  Widget _getCard() => Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Constants.borderRadius),
        ),
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
  Widget build(BuildContext context) {
    Widget dragTargetChild;
    // if (frame is ViewFrame) {
    // var selfAsFrame = frame as ViewFrame;

    var children = widget.frame.children
        .map<Widget>(
          (c) => Expanded(
            child: ViewFrameCard(
              frame: c,
            ),
          ),
        )
        .toList();
    if (children.length == 0)
      children.add(
        Expanded(
          child: Placeholder(
            color: Colors.blue,
          ),
        ),
      );

    if (widget.frame.layout == FrameLayout.VERTICAL) {
      dragTargetChild = Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    } else {
      dragTargetChild = Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    // } else {
    //   dragTargetChild = Placeholder(
    //     color: Colors.red,
    //   );
    // }

    return DragTarget(
      builder: (context, candidateList, rejectedData) => dragTargetChild,
      onWillAccept: (value) {
        log(value.toString());
        return true;
      },
      onAccept: (ViewFrame value) {
        log(value.toString());
        setState(() {
          widget.frame.children.add(value);
          value.layout = widget.frame.layout == FrameLayout.VERTICAL
              ? FrameLayout.HORIZONTAL
              : FrameLayout.VERTICAL;
        });
      },
    );
  }
}
