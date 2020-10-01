import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';

abstract class TemplateFieldWidget extends StatefulWidget {
  final Template template;
  final TemplateField field;

  const TemplateFieldWidget({
    Key key,
    @required this.field,
    @required this.template,
  }) : super(key: key);
}

abstract class TemplateFieldWidgetState extends State<TemplateFieldWidget> {
  @protected
  TextEditingController nameController;
  @protected
  FocusNode nameFocusNode;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.field.name);
    nameFocusNode = FocusNode();

    nameFocusNode.addListener(() {
      if (nameFocusNode.hasFocus) {
        nameController.selection = TextSelection(
            baseOffset: 0, extentOffset: nameController.text.length);
      }
    });
    super.initState();
  }
}
