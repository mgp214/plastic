import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/model/view/view_widgets/empty_widget.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/view/edit_view_page.dart';
import 'package:plastic/widgets/view/view_frame_card.dart';

class ViewPage extends StatefulWidget {
  final View view;

  const ViewPage({Key key, @required this.view}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ViewPageState();
}

class ViewPageState extends State<ViewPage> {
  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() {
    var widgets = _getAllWidgets(widget.view.root);
    for (var w in widgets) {
      w.getData();
      w.triggerRebuild = () {
        setState(() {});
      };
    }
    setState(() {});
  }

  List<ViewWidget> _getAllWidgets(Frame frame) {
    var result = List<ViewWidget>();
    if (frame.widget != null && frame.widget.runtimeType != EmptyWidget) {
      result.add(frame.widget);
    }
    for (var cf in frame.childFrames) {
      result.addAll(_getAllWidgets(cf));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Motif.background,
      body: Stack(
        children: [
          RefreshIndicator(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  child: ViewFrameCard(
                    frame: widget.view.root,
                    rebuildLayout: (isDragging) => setState(() {}),
                    resetLayout: (f) => setState(() {
                      widget.view.root = f;
                    }),
                    isLocked: true,
                    isEditing: false,
                  ),
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              onRefresh: () => Future(refresh)),
          Positioned(
            bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
            right: 10,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Motif.title, width: 3),
                      bottom: BorderSide(color: Motif.title, width: 3),
                      right: BorderSide(color: Motif.title, width: 3),
                      left: BorderSide(color: Motif.title, width: 3),
                    ),
                    shape: BoxShape.circle,
                    color: Motif.background,
                  ),
                  child: InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.edit,
                        color: Motif.title,
                        size: Constants.iconSize,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditViewPage(
                            view: widget.view,
                          ),
                        ),
                      ).then((value) => refresh());
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
