import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view_widgets/count_widget.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/view/condition/condition_builder.dart';
import 'package:plastic/widgets/view/view_frame_card.dart';
import 'package:plastic/widgets/view/widgets/count_widget_widget.dart';

class ViewWidgetProvider {
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
              CountWidget(),
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
      ];

  static Widget _getEditWidgetInternal(ViewWidget viewWidget) {
    if (viewWidget is CountWidget) {
      return CountWidgetWidget(countWidget: viewWidget);
    }
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
  }

  static Widget getEditWidget(BuildContext context, ViewFrameCard frameCard) {
    var viewWidget = frameCard.frame.widget;
    if (viewWidget == null)
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

    return Stack(
      children: [
        _getEditWidgetInternal(viewWidget),
        Positioned(
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
        )
      ],
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
                  countWidget.getData();
                },
              ),
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
          frameCard.frame.widget = null;
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
