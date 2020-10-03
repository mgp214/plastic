import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/model/motif.dart';

class DoubleField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final TextStyle labelStyle;
  final Color fillColor;
  final void Function(String) onChanged;
  final String label;

  const DoubleField(
      {Key key,
      @required this.controller,
      @required this.onChanged,
      this.focusNode,
      this.style,
      this.labelStyle,
      this.label,
      this.fillColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(3),
        child: TextField(
          decoration: InputDecoration(
            fillColor: fillColor,
            filled: fillColor != null,
            labelText: label ?? "",
            labelStyle:
                labelStyle ?? Motif.contentStyle(Sizes.Label, Motif.black),
          ),
          style: style ?? Motif.contentStyle(Sizes.Content, Motif.black),
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
              return double.tryParse(newValue.text) == null
                  ? oldValue
                  : newValue;
            }),
          ],
        ),
      );
}
