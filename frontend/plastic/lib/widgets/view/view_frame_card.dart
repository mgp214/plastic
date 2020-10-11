import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/model/view/view_frame.dart';
import 'package:plastic/model/view/view_widget.dart';
import 'package:plastic/utility/constants.dart';

class ViewFrameCard extends StatefulWidget {
  final Frame frame;

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

  void onAcceptDrag(dynamic value) {
    if (value is ViewWidget) {
    } else if (value == FrameLayout.VERTICAL) {
      if (widget.frame.layout == FrameLayout.VERTICAL) {
        if (widget.frame.parent != null) {
          setState(() {
            var insertIndex =
                widget.frame.parent.childFrames.indexOf(widget.frame);
            widget.frame.parent.childFrames.insert(
              insertIndex,
              Frame(
                parent: widget.frame.parent,
                layout: FrameLayout.VERTICAL,
              ),
            );
          });
        }
      } else {
        setState(() {
          widget.frame.childFrames.add(
            Frame(
              parent: widget.frame,
              layout: FrameLayout.VERTICAL,
            ),
          );
          widget.frame.childFrames.add(
            Frame(
              parent: widget.frame,
              layout: FrameLayout.VERTICAL,
            ),
          );
        });
      }
    } else if (value == FrameLayout.HORIZONTAL) {
      if (widget.frame.layout == FrameLayout.HORIZONTAL) {
        setState(() {
          var insertIndex =
              widget.frame.parent.childFrames.indexOf(widget.frame);
          widget.frame.parent.childFrames.insert(
            insertIndex,
            Frame(
              parent: widget.frame.parent,
              layout: FrameLayout.HORIZONTAL,
            ),
          );
        });
      } else {
        setState(() {
          widget.frame.childFrames.add(
            Frame(
              parent: widget.frame,
              layout: FrameLayout.HORIZONTAL,
            ),
          );
          widget.frame.childFrames.add(
            Frame(
              parent: widget.frame,
              layout: FrameLayout.HORIZONTAL,
            ),
          );
        });
      }
    }

    // setState(() {
    //   widget.frame.children.add(value);
    //   value.layout = widget.frame.layout == FrameLayout.VERTICAL
    //       ? FrameLayout.HORIZONTAL
    //       : FrameLayout.VERTICAL;
    // });
  }

  @override
  Widget build(BuildContext context) {
    Widget dragTargetChild;
    // if (frame is ViewFrame) {
    // var selfAsFrame = frame as ViewFrame;

    var children = widget.frame.childFrames
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
    if (widget.frame.childFrames.length == 0) {
      return DragTarget(
        builder: (context, candidateList, rejectedData) {
          if (candidateList.length > 0) {
            return Placeholder(
              color: Colors.red,
            );
          }
          return dragTargetChild;
        },
        onWillAccept: (dynamic value) {
          return true;
        },
        onAccept: (value) => onAcceptDrag(value),
      );
    } else {
      return dragTargetChild;
    }
  }
}
