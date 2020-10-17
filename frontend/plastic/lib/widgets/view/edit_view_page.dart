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
  bool _isDragging;

  @override
  initState() {
    _isDragging = false;
    super.initState();
  }

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

  Widget _getPositionedAction() {
    if (_isDragging == false)
      return Draggable(
        feedback: _getAddFrame(Colors.transparent),
        child: _getAddFrame(Motif.background),
        data: null as dynamic,
        onDragCompleted: () => setState(() {
          _isDragging = false;
        }),
        onDraggableCanceled: (v, o) => setState(() {
          _isDragging = false;
        }),
        onDragStarted: () => setState(() {
          _isDragging = true;
        }),
      );
    return DragTarget(
      builder: (context, candidateData, rejectedData) => Card(
        color: Motif.background,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.delete,
            color: Motif.title,
            size: Constants.iconSize,
          ),
        ),
      ),
      onWillAccept: (candidate) => true,
      onAccept: (candidate) => setState(() {
        _isDragging = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        child: Scaffold(
          backgroundColor: Motif.background,
          body: Stack(
            children: [
              ViewFrameCard(
                frame: widget.view.root,
                rebuildLayout: (isDragging) => setState(() {
                  _isDragging = isDragging;
                }),
                resetLayout: (f) => setState(() {
                  _isDragging = false;
                  widget.view.root = f;
                }),
              ),
              Positioned(
                bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
                right: 10,
                child: _getPositionedAction(),
                // Draggable(
                //   feedback: _getAddFrame(Colors.transparent),
                //   child: _getAddFrame(Motif.background),
                //   data: null as dynamic,
                //   onDragCompleted: () => setState(() {}),
                // ),
              )
            ],
          ),
        ),
        onWillPop: () {
          return Future.value(true);
        },
      );
}
