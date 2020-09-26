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
  static final Color background = Color.fromARGB(255, 25, 25, 25);
  static final Color primary = Colors.yellow[600];
  static final Color white = Colors.white;
  static final Color error = Colors.red[300];
  static final Color delete = Colors.red;
  static final Color black = Colors.black87;
  static final Color inputField = Color.fromARGB(255, 46, 46, 46);
  static final Color accent = Colors.lightBlue[300];
  static final Color disabled = Colors.white54;

  static final Duration snackDuration = Duration(milliseconds: 4);

  static final double _borderRadius = 8;
  static final Radius borderRadius = Radius.circular(_borderRadius);

  static final _fontRoleSizeMap = <FontRole, double>{
    FontRole.Title: 96,
    FontRole.Display1: 48,
    FontRole.Display2: 36,
    FontRole.Display3: 28,
    FontRole.Content: 24,
    FontRole.Tooltip: 16,
  };

  static final _fontRoleFamilyMap = <FontRole, String>{
    FontRole.Title: 'Geo',
    FontRole.Display1: 'Geo',
    FontRole.Display2: 'Geo',
    FontRole.Display3: 'Geo',
    FontRole.Content: 'Ubuntu',
    FontRole.Tooltip: 'Ubuntu',
  };

  static TextStyle getStyle(FontRole fontRole, Color color) {
    return TextStyle(
      fontSize: _fontRoleSizeMap[fontRole],
      fontFamily: _fontRoleFamilyMap[fontRole],
      foreground: Paint()..color = color,
      letterSpacing: fontRole == FontRole.Title ? 0 : 0,
    );
  }
}
