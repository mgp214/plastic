import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';

class ViewWidgetProvider {
  static List<DialogChoice> getAvailableWidgets() => [];

  static Widget _getEditWidgetInternal(ViewWidget viewWidget) {
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

  static Widget getEditWidget(BuildContext context, ViewWidget viewWidget) {
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
                  choices: getAvailableWidgets(),
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
              color: Motif.black,
            ),
            onPressed: () => showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                      contentPadding: EdgeInsets.all(15),
                      children: [
                        getEditConsole(viewWidget),
                      ],
                    )),
          ),
        )
      ],
    );
  }

  static Widget getEditConsole(ViewWidget viewWidget) {
    return Column(
      children: [
        Text(
          "This is where all the options and parameters you can change for this particular type of widget show up!",
          style: Motif.contentStyle(Sizes.Content, Motif.black),
        ),
      ],
    );
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
