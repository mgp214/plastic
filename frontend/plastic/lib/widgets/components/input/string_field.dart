import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';

class StringField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final TextStyle labelStyle;
  final Color fillColor;
  final void Function(String) onChanged;
  final String label;

  const StringField({
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
        ),
      );
}
