import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/model/motif.dart';

class IntField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final TextStyle labelStyle;
  final void Function(String) onChanged;
  final Color fillColor;
  final String label;

  const IntField({
    Key key,
    @required this.controller,
    @required this.onChanged,
    this.focusNode,
    this.style,
    this.labelStyle,
    this.label,
    this.fillColor,
  }) : super(key: key);

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
              TextInputType.numberWithOptions(signed: true, decimal: false),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.length == 1 && newValue.text == '-')
                return newValue;
              if (newValue.text.length < oldValue.text.length) return newValue;
              return int.tryParse(newValue.text) == null ? oldValue : newValue;
            }),
          ],
        ),
      );
}
