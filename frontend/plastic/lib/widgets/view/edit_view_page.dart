import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/view/view_frame_card.dart';

class EditViewPage extends StatefulWidget {
  final View view;

  const EditViewPage({Key key, this.view}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditViewPageState();
}

class EditViewPageState extends State<EditViewPage> {
  bool _isDragging;
  bool _isLocked;

  @override
  initState() {
    _isDragging = false;
    _isLocked = false;
    super.initState();
  }

  Widget _getAddFrame(Color background) => Container(
        decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Motif.title, width: 3),
              bottom: BorderSide(color: Motif.title, width: 3),
              right: BorderSide(color: Motif.title, width: 3),
              left: BorderSide(color: Motif.title, width: 3),
            ),
            shape: BoxShape.circle,
            color: _isLocked ? Motif.neutral : background),
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
        maxSimultaneousDrags: _isLocked ? 0 : 1,
        feedback:
            _getAddFrame(Color.lerp(Colors.transparent, Motif.background, 0.5)),
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
      builder: (context, candidateData, rejectedData) => Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Motif.background),
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
                isLocked: _isLocked,
              ),
              Positioned(
                bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
                right: 10,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: _getPositionedAction(),
                    ),
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
                            Icons.menu,
                            color: Motif.title,
                            size: Constants.iconSize,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => ChoiceActionsDialog(
                                    message: null,
                                    choices: [
                                      DialogTextIconChoice(
                                          _isLocked
                                              ? "Unlock layout"
                                              : "Lock layout",
                                          _isLocked
                                              ? Icons.lock_open
                                              : Icons.lock,
                                          Motif.black, () {
                                        setState(() {
                                          _isLocked = !_isLocked;
                                        });
                                        Navigator.pop(context);
                                      })
                                    ],
                                  ));
                        },
                      ),
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
