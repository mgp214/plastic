import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/model/view/view_frame.dart';
import 'package:plastic/model/view/view_widget.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/view/view_frame_card.dart';

class EditViewPage extends StatefulWidget {
  final View view;

  const EditViewPage({Key key, this.view}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditViewPageState();
}

class EditViewPageState extends State<EditViewPage> {
  // Random random = Random();

  Widget _getViewWidgetWidget(ViewWidget viewWidget) {
    if (viewWidget is ViewFrame) {
      return _getFrameWidget(viewWidget);
    } else {
      return _getWidgetWidget(viewWidget);
    }
  }

  Widget _getWidgetWidget(ViewWidget viewWidget) {
    return Container(
        child: Placeholder(
      color: Motif.title,
    ));
  }

  Widget _getFrameWidget(ViewFrame frame) {
    List<Widget> childrenWidgets = List();
    childrenWidgets.addAll(
      frame.children
          .map((c) => Expanded(
                child: _getViewWidgetWidget(c),
              ))
          .toList(),
    );

    List<Widget> actions = [
      IconButton(
        icon: Icon(
          Icons.add_circle_outline,
          size: Constants.iconSize,
        ),
        onPressed: () {},
      ),
    ];

    Widget actionsChild;
    if (frame.layout == FrameLayout.VERTICAL) {
      actionsChild = Row(
        children: actions,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
    } else {
      actionsChild = Column(
        children: actions,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
    }

    childrenWidgets.add(
      Expanded(child: actionsChild),
    );

    Widget laidOutChildren;
    if (frame.layout == FrameLayout.VERTICAL) {
      laidOutChildren = Container(
        decoration: BoxDecoration(
          color: Colors.purple,
        ),
        child: Column(
          children: childrenWidgets,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: childrenWidgets.length == 1
              ? MainAxisAlignment.spaceAround
              : MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      );
    } else {
      laidOutChildren = Container(
        decoration: BoxDecoration(
          color: Colors.purple,
        ),
        child: Row(
          children: childrenWidgets,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      );
    }

    return laidOutChildren;
  }

  Widget _getAddWidget(Color background) => Card(
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

  Widget _getHorizontalSplitWidget(Color background) => Card(
        color: background,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.border_horizontal,
            color: Motif.title,
            size: Constants.iconSize,
          ),
        ),
      );

  Widget _getVerticalSplitWidget(Color background) => Card(
        color: background,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.border_vertical,
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
              ),
              Positioned(
                bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
                right: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Draggable(
                      feedback: _getHorizontalSplitWidget(Colors.transparent),
                      child: _getHorizontalSplitWidget(Motif.lightBackground),
                      data: FrameLayout.HORIZONTAL as dynamic,
                      onDragCompleted: () => setState(() {}),
                    ),
                    Draggable(
                      feedback: _getVerticalSplitWidget(Colors.transparent),
                      child: _getVerticalSplitWidget(Motif.lightBackground),
                      data: FrameLayout.VERTICAL as dynamic,
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
