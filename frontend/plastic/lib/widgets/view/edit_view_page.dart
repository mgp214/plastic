import 'package:flutter/material.dart';
import 'package:plastic/api/view_api.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/model/view/view_widgets/empty_widget.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:plastic/widgets/components/input/string_field.dart';
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
  TextEditingController _nameController;

  @override
  initState() {
    _isDragging = false;
    _isLocked = false;
    _nameController = TextEditingController(text: widget.view.name);
    var widgets = _getAllWidgets(widget.view.root);
    for (var w in widgets) {
      w.triggerRebuild = () => setState(() {
            _isDragging = false;
          });
    }
    super.initState();
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
  Widget build(BuildContext context) {
    var choices = List<DialogChoice>();
    choices.add(
      DialogTextChoice("Edit name", Motif.black, () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => WillPopScope(
            child: Dialog(
              child: Material(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  StringField(controller: _nameController, onChanged: null),
                  BorderButton(
                      color: Motif.neutral,
                      content: "Save",
                      onPressed: () {
                        setState(() {
                          widget.view.name = _nameController.text;
                        });
                        Navigator.pop(context);
                      }),
                  BorderButton(
                      color: Motif.negative,
                      content: "Cancel",
                      onPressed: () {
                        _nameController.value =
                            TextEditingValue(text: widget.view.name ?? "");
                        Navigator.pop(context);
                      }),
                ]),
              ),
            ),
            onWillPop: () {
              _nameController.value =
                  TextEditingValue(text: widget.view.name ?? "");
              return Future.value(true);
            },
          ),
        );
      }),
    );
    choices.add(DialogTextIconChoice("Save", Icons.save, Motif.black, () {
      ViewApi().saveView(context, widget.view);
      Navigator.pop(context);
    }));
    if (widget.view.id != null)
      choices.add(DialogTextIconChoice("Delete", Icons.delete, Motif.black, () {
        ViewApi().deleteView(context, widget.view);
        Navigator.pop(context);
        Navigator.pop(context);
      }));
    choices.add(DialogTextIconChoice(
        _isLocked ? "Unlock layout" : "Lock layout",
        _isLocked ? Icons.lock_open : Icons.lock,
        Motif.black, () {
      setState(() {
        _isLocked = !_isLocked;
      });
      Navigator.pop(context);
    }));
    return WillPopScope(
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
              isEditing: true,
            ),
            Positioned(
              bottom: 10,
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
                                  choices: choices,
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
}
