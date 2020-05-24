import 'package:flutter/material.dart';

enum FontRole {
  Title,
  Display1,
  Display2,
  Display3,
  Content,
  Tooltip,
}

enum FontColor {
  White,
  Error,
  Black,
  Primary,
  Accent,
  Disabled,
}

class Style {
  static final Color background = Color.fromARGB(230, 0, 0, 0);
  static final Color primary = Colors.yellow[600];
  static final Color white = Colors.white;
  static final Color error = Colors.red[300];
  static final Color black = Colors.black87;
  static final Color inputField = Colors.white54;
  static final Color accent = Colors.lightBlue[300];
  static final Color disabled = Colors.white54;

  static final _fontRoleMap = <FontRole, double>{
    FontRole.Title: 64,
    FontRole.Display1: 48,
    FontRole.Display2: 28,
    FontRole.Display3: 18,
    FontRole.Content: 12,
    FontRole.Tooltip: 10,
  };

  static TextStyle getStyle(FontRole fontRole, Color color) {
    return TextStyle(
      fontSize: _fontRoleMap[fontRole],
      foreground: fontRole == FontRole.Title
          ? (Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = color)
          : Paint()
        ..color = color,
      letterSpacing: fontRole == FontRole.Title ? 20 : 0,
    );
  }
}
