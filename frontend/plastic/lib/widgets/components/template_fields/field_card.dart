import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/utility/style.dart';
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
        color: Style.inputField,
        child: Stack(
          children: [
            SplashListTile(
              color: Style.accent,
              onTap: () => Flushbar(
                message: "Hold to rearrange fields",
                duration: Style.snackDuration,
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
                          color: Style.background,
                          indent: 10,
                          endIndent: 10,
                        ),
                        Icon(
                          Icons.reorder,
                          color: Style.background,
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
                color: Style.error,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      backgroundColor: Style.background,
                      title: Text(
                        "Are you sure you want to delete field \"${fieldWidget.field.name}\"?",
                        style: Style.getStyle(FontRole.Display3, Style.primary),
                      ),
                      children: [
                        SimpleDialogOption(
                          child: Text(
                            "Delete",
                            style:
                                Style.getStyle(FontRole.Display3, Style.error),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                        ),
                        SimpleDialogOption(
                          child: Text(
                            "Cancel",
                            style:
                                Style.getStyle(FontRole.Display3, Style.accent),
                          ),
                          onPressed: () => Navigator.pop(context),
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
