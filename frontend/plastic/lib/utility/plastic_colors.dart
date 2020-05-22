import 'package:flutter/material.dart';

enum FontRole {
  Display1,
  Display2,
  Display3,
  Content,
  Tooltip,
}

enum FontColor {
  White,
  Black,
  Primary,
  Accent,
  Disabled,
}

class PlasticColors {
  static final Color background = black;
  static final Color primary = Colors.purple;
  static final Color white = Colors.white;
  static final Color black = Colors.black87;
  static final Color inputField = Colors.white54;
  static final Color accent = Colors.orangeAccent[400];

  static final _fontRoleMap = <FontRole, double>{
    FontRole.Display1: 48,
    FontRole.Display2: 28,
    FontRole.Display3: 18,
    FontRole.Content: 12,
    FontRole.Tooltip: 10,
  };

  static final _fontColorMap = <FontColor, Color>{
    FontColor.White: white,
    FontColor.Black: Colors.black87,
    FontColor.Primary: primary,
    FontColor.Accent: Colors.yellow,
    FontColor.Disabled: Colors.white54,
  };

  static TextStyle getStyle(FontRole fontRole, FontColor fontColor) {
    return TextStyle(
        fontSize: _fontRoleMap[fontRole], color: _fontColorMap[fontColor]);
  }
}
