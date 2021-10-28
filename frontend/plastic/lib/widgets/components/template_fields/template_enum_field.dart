import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/widgets/components/input/string_field.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';
import 'package:plastic/widgets/components/template_fields/template_field.dart';

class TemplateEnumField extends TemplateFieldWidget {
  TemplateEnumField({
    Key key,
    @required TemplateField field,
    @required template,
  }) : super(key: key, field: field, template: template);

  @override
  State<StatefulWidget> createState() => TemplateEnumFieldState();
}

class TemplateEnumFieldState extends TemplateFieldWidgetState {
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
  Widget build(BuildContext context) {
    var children = List<Widget>();
    children.add(
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
    );
    children.add(
      StringField(
        fillColor: Motif.background,
        controller: _valueController,
        focusNode: _valueFocusNode,
        label: "Add a choice",
        onChanged: (value) {},
        onSubmitted: (value) {
          if (widget.field.choices.indexOf(value) == -1) {
            setState(() {
              widget.field.choices.add(value);
              _valueController.text = '';
            });
          }
        },
      ),
    );
    for (var choice in widget.field.choices) {
      children.add(SplashListTile(
          child: Row(
            children: [
              Text(choice,
                  style: Motif.contentStyle(Sizes.Content, Motif.black)),
              IconButton(
                  icon: Icon(Icons.cancel_outlined),
                  onPressed: () {
                    setState(() {
                      widget.field.choices.remove(choice);
                    });
                  })
            ],
          ),
          color: Motif.neutral,
          onTap: null));
    }
    return Column(
      children: children,
    );
  }
}
