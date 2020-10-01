import 'package:flutter/material.dart';
import 'package:plastic/utility/style.dart';

abstract class DialogChoice {
  final Color color;
  final VoidCallback action;

  DialogChoice(this.color, this.action);

  Widget build();
}

class DialogTextChoice extends DialogChoice {
  final String text;

  DialogTextChoice(this.text, Color color, VoidCallback action)
      : super(color, action);

  @override
  Widget build() => SimpleDialogOption(
        child: Text(
          text,
          style: Style.getStyle(FontRole.Display3, color),
        ),
        onPressed: action,
      );
}

class DialogTextIconChoice extends DialogChoice {
  final IconData icon;
  final String text;

  DialogTextIconChoice(this.text, this.icon, Color color, VoidCallback action)
      : super(color, action);

  @override
  Widget build() => SimpleDialogOption(
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
            ),
            Text(text, style: Style.getStyle(FontRole.Display3, color)),
          ],
        ),
        onPressed: action,
      );
}