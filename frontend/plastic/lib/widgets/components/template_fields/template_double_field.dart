import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/widgets/components/input/double_field.dart';
import 'package:plastic/widgets/components/input/string_field.dart';
import 'package:plastic/widgets/components/template_fields/template_field.dart';

class TemplateDoubleField extends TemplateFieldWidget {
  TemplateDoubleField({
    Key key,
    @required TemplateField field,
    @required template,
  }) : super(key: key, field: field, template: template);

  @override
  State<StatefulWidget> createState() => TemplateDoubleFieldState();
}

class TemplateDoubleFieldState extends TemplateFieldWidgetState {
  TextEditingController _valueController;
  FocusNode _valueFocusNode;

  @override
  void initState() {
    _valueController =
        TextEditingController(text: widget.field.defaultValue.toString());
    _valueFocusNode = FocusNode();

    _valueFocusNode.addListener(() {
      if (_valueFocusNode.hasFocus) {
        _valueController.selection = TextSelection(
            baseOffset: 0, extentOffset: _valueController.text.length);
      }
    });
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
          DoubleField(
            controller: _valueController,
            focusNode: _valueFocusNode,
            label: "Default value",
            onChanged: (value) {
              setState(() {
                widget.field.defaultValue = double.parse(value, (value) => 0);
              });
            },
          ),
        ],
      );
}
