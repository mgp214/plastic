import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/widgets/components/input/string_field.dart';
import 'package:plastic/widgets/components/template_fields/template_field.dart';

class TemplateDateField extends TemplateFieldWidget {
  TemplateDateField({
    Key key,
    @required TemplateField field,
    @required template,
  }) : super(key: key, field: field, template: template);

  @override
  State<StatefulWidget> createState() => TemplateDateFieldState();
}

class TemplateDateFieldState extends TemplateFieldWidgetState {
  @override
  Widget build(BuildContext context) => Column(children: [
        StringField(
          fillColor: Motif.background,
          controller: nameController,
          focusNode: nameFocusNode,
          label: "Field name",
          onChanged: (value) {
            setState(() {
              widget.field.name = value;
            });
          },
        ),
        Text(
          "Defaults to the current day",
          style: Motif.contentStyle(Sizes.Label, Motif.black),
        )
      ]);
}
