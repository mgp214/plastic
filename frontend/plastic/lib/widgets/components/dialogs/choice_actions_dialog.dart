import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';

class ChoiceActionsDialog extends StatelessWidget {
  final String message;
  final List<DialogChoice> choices;
  // final Map<String, VoidCallback> actions;

  const ChoiceActionsDialog({
    Key key,
    @required this.message,
    @required this.choices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SimpleDialog(
        backgroundColor: Motif.lightBackground,
        title: message == null
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  message,
                  style: Motif.contentStyle(Sizes.Content, Motif.black),
                ),
              ),
        children: choices
            .map(
              (e) => e.build(),
            )
            .toList(),
      );
}
