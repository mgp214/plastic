import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/utility/style.dart';

class StringField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final TextStyle labelStyle;
  final void Function(String) onChanged;
  final String label;

  const StringField(
      {Key key,
      @required this.controller,
      @required this.onChanged,
      this.focusNode,
      this.style,
      this.labelStyle,
      this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) => TextField(
        decoration: InputDecoration(
          labelText: label ?? "",
          labelStyle:
              labelStyle ?? Style.getStyle(FontRole.Display3, Style.accent),
        ),
        style: style ?? Style.getStyle(FontRole.Display2, Style.primary),
        controller: controller,
        focusNode: focusNode ?? FocusNode(),
        onChanged: onChanged,
      );
}
