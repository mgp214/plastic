import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/widgets/components/checkbox_field.dart';
import 'package:plastic/widgets/components/string_field.dart';
import 'package:plastic/widgets/components/template_fields/template_field.dart';

class TemplateBoolField extends TemplateFieldWidget {
  TemplateBoolField({
    Key key,
    @required TemplateField field,
    @required template,
  }) : super(key: key, field: field, template: template);

  @override
  State<StatefulWidget> createState() => TemplateBoolFieldState();
}

class TemplateBoolFieldState extends TemplateFieldWidgetState {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          StringField(
            controller: nameController,
            focusNode: nameFocusNode,
            label: "Field name",
            onChanged: (value) {
              setState(() {
                widget.field.name = value;
              });
            },
          ),
          CheckboxField(
            onChanged: (value) {
              setState(() {
                widget.field.defaultValue = value ?? false;
              });
            },
            label: "Default state",
            value: widget.field.defaultValue ?? null,
          )
        ],
      );
}
