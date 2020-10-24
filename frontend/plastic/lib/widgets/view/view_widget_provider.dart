import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';
import 'package:plastic/widgets/view/view_frame_card.dart';

class ViewWidgetProvider {
  static VoidCallback _getAddWidgetFunction(
      BuildContext context, ViewFrameCard frameCard, ViewWidget viewWidget) {
    return () {
      frameCard.frame.widget = viewWidget;
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
              ViewWidget(),
            )),
        DialogTextIconChoice(
            "Thing Count",
            Icons.filter_1,
            Motif.title,
            _getAddWidgetFunction(
              context,
              frameCard,
              ViewWidget(),
            )),
      ];

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
              color: Motif.black,
            ),
            onPressed: () => showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                      contentPadding: EdgeInsets.all(15),
                      children: [
                        getEditConsole(context, frameCard),
                      ],
                    )),
          ),
        )
      ],
    );
  }

  static Widget getEditConsole(BuildContext context, ViewFrameCard frameCard) {
    return Column(
      children: [
        SplashListTile(
          color: Motif.negative,
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: Motif.negative,
                size: Constants.iconSize,
              ),
              Text(
                "Delete",
                style: Motif.contentStyle(Sizes.Content, Motif.negative),
              ),
            ],
          ),
          onTap: () {
            frameCard.frame.widget = null;
            frameCard.rebuildLayout(false);
            Navigator.pop(context);
          },
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
