import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';
import 'package:plastic/widgets/components/template_fields/template_field.dart';

class FieldCard extends StatelessWidget {
  final Template template;
  final TemplateFieldWidget fieldWidget;
  final VoidCallback onDelete;
  const FieldCard({
    Key key,
    @required this.template,
    @required this.fieldWidget,
    @required this.onDelete,
  }) : super(key: key);

  Widget build(BuildContext context) => Card(
        key: key,
        color: Motif.lightBackground,
        child: Stack(
          children: [
            SplashListTile(
              color: Motif.title,
              onTap: () => Flushbar(
                backgroundColor: Motif.background,
                message: "Hold to rearrange fields",
                duration: Constants.snackDuration,
              ).show(context),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: fieldWidget,
                        ),
                        VerticalDivider(
                          width: 15,
                          thickness: 1,
                          color: Motif.background,
                          indent: 10,
                          endIndent: 10,
                        ),
                        Icon(
                          Icons.reorder,
                          color: Motif.neutral,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: 0,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                ),
                color: Motif.negative,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ChoiceActionsDialog(
                      message:
                          "Are you sure you want to delete field \"${fieldWidget.field.name}\"?",
                      choices: [
                        DialogTextChoice(
                          "Delete",
                          Motif.negative,
                          () {
                            Navigator.pop(context);
                            onDelete();
                          },
                        ),
                        DialogTextChoice(
                          "Cancel",
                          Motif.black,
                          () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
}
