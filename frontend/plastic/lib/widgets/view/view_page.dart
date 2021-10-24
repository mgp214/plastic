import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view.dart';
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
    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Motif.background,
      body: Stack(
        children: [
          ViewFrameCard(
            frame: widget.view.root,
            rebuildLayout: (isDragging) => setState(() {}),
            resetLayout: (f) => setState(() {
              widget.view.root = f;
            }),
            isLocked: true,
            isEditing: false,
          ),
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
