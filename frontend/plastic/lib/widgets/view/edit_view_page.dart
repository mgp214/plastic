import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/model/view/view_frame.dart';
import 'package:plastic/model/view/view_widget.dart';

class EditViewPage extends StatefulWidget {
  final View view;

  const EditViewPage({Key key, this.view}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditViewPageState();
}

class EditViewPageState extends State<EditViewPage> {
  Random random = Random();

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
        icon: Icon(Icons.add_box),
        onPressed: () {
          setState(() {
            frame.children.add(ViewWidget());
          });
        },
      ),
      IconButton(
        icon: Icon(Icons.border_vertical),
        onPressed: () {
          setState(() {
            frame.children.add(ViewFrame(layout: FrameLayout.HORIZONTAL));
          });
        },
      ),
      IconButton(
        icon: Icon(Icons.border_horizontal),
        onPressed: () {
          setState(() {
            frame.children.add(ViewFrame(layout: FrameLayout.VERTICAL));
          });
        },
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
          color: Color.fromARGB(255, random.nextInt(255), random.nextInt(255),
              random.nextInt(255)),
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
          color: Color.fromARGB(255, random.nextInt(255), random.nextInt(255),
              random.nextInt(255)),
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

  @override
  Widget build(BuildContext context) => WillPopScope(
        child: Scaffold(
          backgroundColor: Motif.background,
          body: _getFrameWidget(widget.view.root),
        ),
        onWillPop: () {
          return Future.value(true);
        },
      );
}