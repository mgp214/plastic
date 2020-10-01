import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/utility/style.dart';

class DoubleField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final TextStyle labelStyle;
  final void Function(String) onChanged;
  final String label;

  const DoubleField(
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
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
        inputFormatters: [
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.length == 1 && newValue.text == '-')
              return newValue;
            if (newValue.text.length == 1 && newValue.text == '.')
              return TextEditingValue(
                text: "0.",
                selection: TextSelection.fromPosition(
                  TextPosition(offset: 2),
                ),
              );
            if (newValue.text.length == 2 && newValue.text == '-.')
              return TextEditingValue(
                text: "-0.",
                selection: TextSelection.fromPosition(
                  TextPosition(offset: 3),
                ),
              );
            if (newValue.text.length < oldValue.text.length) return newValue;
            return double.tryParse(newValue.text) == null ? oldValue : newValue;
          }),
        ],
      );
}
