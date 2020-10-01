import 'package:flutter/material.dart';
import 'package:plastic/utility/hex_color.dart';

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
  static final Color background = HexColor.fromHex("#ebfaff");
  static final Color primary = HexColor.fromHex("#d0a011");
  static final Color white = HexColor.fromHex("#E1E1E1");
  static final Color error = HexColor.fromHex("#EC7A7A");
  static final Color delete = HexColor.fromHex("#9D2F38");
  static final Color black = HexColor.fromHex("#2D2529");
  static final Color inputField = HexColor.fromHex("#c2f0ff");
  static final Color accent = HexColor.fromHex("#007da3");
  static final Color disabled = Colors.white54;

  static final Duration snackDuration = Duration(milliseconds: 4000);

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
    FontRole.Display1: 'Asap',
    FontRole.Display2: 'Asap',
    FontRole.Display3: 'Asap',
    FontRole.Content: 'Asap',
    FontRole.Tooltip: 'Asap',
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
