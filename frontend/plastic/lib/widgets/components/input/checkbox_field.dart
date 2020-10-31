import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';

class CheckboxField extends StatelessWidget {
  final FocusNode focusNode;
  final TextStyle labelStyle;
  final void Function(bool) onChanged;
  final String label;
  final Color checkColor;
  final bool value;

  const CheckboxField(
      {Key key,
      @required this.onChanged,
      @required this.value,
      this.focusNode,
      this.labelStyle,
      this.label,
      this.checkColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) => CheckboxListTile(
        title: Text(
          label ?? "",
          style: labelStyle ?? Motif.headerStyle(Sizes.Label, Motif.black),
        ),
        checkColor: checkColor ?? Motif.title,
        onChanged: onChanged,
        activeColor: Motif.background,
        value: value ?? false,
      );
}
