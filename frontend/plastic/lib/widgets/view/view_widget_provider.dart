import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view_widgets/count_widget.dart';
import 'package:plastic/model/view/view_widgets/empty_widget.dart';
import 'package:plastic/model/view/view_widgets/label_widget.dart';
import 'package:plastic/model/view/view_widgets/simple_list_widget.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:plastic/widgets/components/input/string_field.dart';
import 'package:plastic/widgets/view/condition/condition_builder.dart';
import 'package:plastic/widgets/view/view_frame_card.dart';
import 'package:plastic/widgets/view/widgets/count_widget_widget.dart';
import 'package:plastic/widgets/view/widgets/label_widget_widget.dart';
import 'package:plastic/widgets/view/widgets/simple_list_widget_widget.dart';

class ViewWidgetProvider {
  static TextEditingController _controller;
  static VoidCallback _getAddWidgetFunction(
      BuildContext context, ViewFrameCard frameCard, ViewWidget viewWidget) {
    return () {
      frameCard.frame.widget = viewWidget;
      viewWidget.triggerRebuild = () => frameCard.rebuildLayout(false);
      viewWidget.getData();
      Navigator.pop(context);
      frameCard.rebuildLayout(false);
    };
  }

  static List<DialogChoice> _getAvailableWidgets(
          BuildContext context, ViewFrameCard frameCard) =>
      [
        DialogTextIconChoice(
            "Plain List",
            Icons.list,
            Motif.title,
            _getAddWidgetFunction(
              context,
              frameCard,
              SimpleListWidget(),
            )),
        DialogTextIconChoice(
            "Thing Count",
            Icons.filter_1,
            Motif.title,
            _getAddWidgetFunction(
              context,
              frameCard,
              CountWidget(),
            )),
        DialogTextIconChoice(
            "Label",
            Icons.text_fields,
            Motif.title,
            _getAddWidgetFunction(
              context,
              frameCard,
              LabelWidget(),
            )),
      ];

  static Widget _getWidgetInternal(ViewWidget viewWidget, bool isEditing) {
    if (viewWidget is CountWidget) {
      return CountWidgetWidget(countWidget: viewWidget);
    }
    if (viewWidget is SimpleListWidget) {
      return SimpleListWidgetWidget(simpleListWidget: viewWidget);
    }
    if (viewWidget is LabelWidget) {
      return LabelWidgetWidget(labelWidget: viewWidget);
    }

    if (isEditing)
      return Stack(
        children: [
          Placeholder(
            color: Motif.title,
          ),
          Center(
            child: Text(
              'empty',
              style: Motif.headerStyle(Sizes.Header, Motif.black),
            ),
          ),
        ],
      );
    return Container();
  }

  static Widget getEditWidget(
      BuildContext context, ViewFrameCard frameCard, bool isEditing) {
    var viewWidget = frameCard.frame.widget;
    if (viewWidget is EmptyWidget && isEditing)
      return Center(
          child: IconButton(
        icon: Icon(
          Icons.addchart,
          size: Constants.iconSize,
          color: Motif.title,
        ),
        onPressed: () => showDialog(
            context: context,
            builder: (context) => ChoiceActionsDialog(
                  message: null,
                  choices: _getAvailableWidgets(context, frameCard),
                )),
      ));

    var children = List<Widget>();
    children.add(_getWidgetInternal(viewWidget, isEditing));
    if (isEditing) {
      children.add(Positioned(
        top: 5,
        right: 5,
        child: IconButton(
          icon: Icon(
            Icons.settings,
            size: Constants.iconSize,
            color: Motif.title,
          ),
          onPressed: () => showDialog(
              context: context,
              builder: (context) => ChoiceActionsDialog(
                    message: null,
                    choices: getEditParameters(context, frameCard),
                  )),
        ),
      ));
    }
    return Stack(
      children: children,
    );
  }

  static List<DialogChoice> _getEditParametersInternal(
      BuildContext context, ViewFrameCard frameCard) {
    var list = List<DialogChoice>();
    if (frameCard.frame.widget is CountWidget) {
      var countWidget = frameCard.frame.widget as CountWidget;
      list.add(
        DialogTextChoice(
          "Edit count condition",
          Motif.black,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConditionBuilder(
                condition: countWidget.countCondition,
                conditionUpdate: (condition) {
                  countWidget.countCondition = condition;
                  countWidget.getData();
                },
              ),
            ),
          ),
        ),
      );
    }
    if (frameCard.frame.widget is SimpleListWidget) {
      var simpleListWidget = frameCard.frame.widget as SimpleListWidget;
      list.add(
        DialogTextChoice(
          "Edit list condition",
          Motif.black,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConditionBuilder(
                condition: simpleListWidget.condition,
                conditionUpdate: (condition) {
                  simpleListWidget.condition = condition;
                  simpleListWidget.getData();
                },
              ),
            ),
          ),
        ),
      );
    }
    if (frameCard.frame.widget is LabelWidget) {
      var labelWidget = frameCard.frame.widget as LabelWidget;
      _controller = TextEditingController(text: labelWidget.text);
      list.add(
        DialogTextChoice(
          "Label text",
          Motif.black,
          () => showDialog(
            context: context,
            builder: (context) => WillPopScope(
              child: Dialog(
                child: Material(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    StringField(controller: _controller, onChanged: null),
                    BorderButton(
                        color: Motif.neutral,
                        content: "Save",
                        onPressed: () {
                          labelWidget.text = _controller.text;
                          Navigator.pop(context);
                        }),
                    BorderButton(
                        color: Motif.negative,
                        content: "Cancel",
                        onPressed: () {
                          _controller.value =
                              TextEditingValue(text: labelWidget.text ?? "");
                          Navigator.pop(context);
                        }),
                  ]),
                ),
              ),
              onWillPop: () {
                _controller.value =
                    TextEditingValue(text: labelWidget.text ?? "");
                return Future.value(true);
              },
            ),
          ),
        ),
      );
    }
    return list;
  }

  static List<DialogChoice> getEditParameters(
      BuildContext context, ViewFrameCard frameCard) {
    var children = _getEditParametersInternal(context, frameCard);
    children.add(
      DialogTextIconChoice(
        "Delete",
        Icons.delete,
        Motif.negative,
        () {
          frameCard.frame.widget = EmptyWidget();
          frameCard.rebuildLayout(false);
          Navigator.pop(context);
        },
      ),
    );
    return children;
  }

  static Widget getDisplayWidget(ViewWidget viewWidget) {
    return Stack(
      children: [
        Placeholder(
          color: Motif.title,
        ),
        Text('empty')
      ],
    );
  }
}
