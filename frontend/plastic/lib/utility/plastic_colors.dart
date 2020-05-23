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
  Black,
  Primary,
  Accent,
  Disabled,
}

class PlasticColors {
  static final Color background = black;
  static final Color primary = Colors.purple[400];
  static final Color white = Colors.white;
  static final Color black = Color.fromARGB(230, 0, 0, 0);
  static final Color inputField = Colors.white54;
  static final Color accent = Colors.yellow[400];

  static final _fontRoleMap = <FontRole, double>{
    FontRole.Title: 64,
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
      fontSize: _fontRoleMap[fontRole],
      color: _fontColorMap[fontColor],
      letterSpacing: fontRole == FontRole.Title ? 10 : 0,
    );
  }
}
