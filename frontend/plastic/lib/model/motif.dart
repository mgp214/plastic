import 'package:flutter/material.dart';

import 'motif_data.dart';

/// The size context in which the given text is going to be included. Determines size.
enum Sizes {
  /// App title
  Title,

  /// Used for things larger than Label, but smaller than Title
  Header,

  /// Used for the bulk of text
  Content,

  /// used for interactive elements, e.g. buttons.
  Action,

  /// used for labelling things, such as fields.
  Label,

  /// used for snackbars
  Notification,
}

/// theme data, in an easy-to-use format.
class Motif {
  static Color title;
  static Color negative;
  static Color caution;
  static Color neutral;
  static Color lightBackground;
  static Color background;
  static Color black;
  static Color white;

  static TextStyle _getStyle(Fonts font, Sizes size, Color color) => TextStyle(
        color: color,
        fontSize: MotifData.activeMotif.sizeMap[size],
        fontFamily: MotifData.activeMotif.fontMap[font],
      );

  static TextStyle titleStyle(Sizes size, Color color) =>
      _getStyle(Fonts.Title, size, color);
  static TextStyle actionStyle(Sizes size, Color color) =>
      _getStyle(Fonts.Action, size, color);
  static TextStyle headerStyle(Sizes size, Color color) =>
      _getStyle(Fonts.Header, size, color);
  static TextStyle contentStyle(Sizes size, Color color) =>
      _getStyle(Fonts.Content, size, color);
}
