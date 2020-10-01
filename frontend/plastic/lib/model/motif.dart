import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plastic/utility/hex_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The role the given text is playing. Determines font
enum Fonts {
  /// used for the app title screen
  Title,

  /// used for interactive elements, e.g. buttons.
  Action,

  /// used for view, template, and thing names and field labels
  Header,

  /// used for general content, such as field values
  Content,
}

/// The size context in which the given text is going to be included. Determines size.
enum Sizes {
  /// App title
  Title,

  /// used for interactive elements, e.g. buttons.
  Action,

  /// used for labelling things, such as fields.
  Label,

  /// used for elements the user can enter text in.
  Input,

  /// used for snackbars
  Notification,
}

/// Used to select colors for specific meanings
enum TextColor {
  Title,
  Template,
  Thing,
  View,
  Negative,
  Neutral,
  Positive,
  Modal,
  Background
}

class Motif {
  static const String FONTS_KEY = "motif.fonts";
  static const String SIZE_KEY = "motif.textSizes";
  static const String COLOR_KEY = "motif.colors";

  final Map<Fonts, String> fontMap;
  final Map<Sizes, double> sizeMap;
  // final Map<TextColor, Color> colorMap;

  final MotifColors colors;

  Motif({this.colors, this.fontMap, this.sizeMap});

  static Motif activeMotif;
  static MotifColors getColors() => activeMotif.colors;

  static Motif getDefault() {
    return Motif(
      fontMap: {
        Fonts.Title: "Geo",
        Fonts.Action: "Ubuntu",
        Fonts.Header: "Ubuntu",
        Fonts.Content: "Ubuntu",
      },
      sizeMap: {
        Sizes.Title: 96,
        Sizes.Action: 28,
        Sizes.Label: 26,
        Sizes.Input: 20,
        Sizes.Notification: 16,
      },
      colors: MotifColors(
        title: HexColor.fromHex("#98C1D9"),
        template: HexColor.fromHex("#B292B5"),
        thing: HexColor.fromHex("#98C1D9"),
        view: HexColor.fromHex("#EBD270"),
        negative: HexColor.fromHex("#9D2F38"),
        neutral: HexColor.fromHex("#30884D"),
        positive: HexColor.fromHex("#2D2529"),
        modal: HexColor.fromHex("#EDE9EB"),
        background: HexColor.fromHex("#D1C7CF"),
      ),
    );
  }

  /// saves this Theme to preferences and caches it.
  Future saveToPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setStringList(
        FONTS_KEY,
        fontMap.entries
            .map<String>((e) => "${describeEnum(e.key)}:${e.value}")
            .toList());
    preferences.setStringList(
        SIZE_KEY,
        sizeMap.entries
            .map<String>((e) => "${describeEnum(e.key)}:${e.value}")
            .toList());
    preferences.setStringList(COLOR_KEY, colors.toList());

    activeMotif = this;
  }

  /// gets the cached motif, failing that loads it from preferences, failing that caches and returns the default motif
  static Future<Motif> getMotif() async {
    if (activeMotif != null) return activeMotif;

    Motif motif;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // if (!preferences.containsKey(FONTS_KEY) ||
    //     !preferences.containsKey(SIZE_KEY) ||
    //     !preferences.containsKey(COLOR_KEY)) {
    //   // no valid motif stored in prefs, get the default motif and save it to prefs.
    //   motif = getDefault();
    //   motif.saveToPreferences();
    //   return motif;
    // }

    // motif is present in prefs but is not loaded. load it and cache.

    motif = Motif(
      fontMap: Map(),
      sizeMap: Map(),
      colors: MotifColors.fromList(
        preferences.getStringList(COLOR_KEY),
      ),
    );
    // load text roles
    for (var font in preferences.getStringList(FONTS_KEY)) {
      var key = Fonts.values
          .firstWhere((e) => describeEnum(e) == font.split(':').first);
      var value = font.split(':').last;
      motif.fontMap[key] = value;
    }

    // load text contexts
    for (var textSize in preferences.getStringList(SIZE_KEY)) {
      var key = Sizes.values
          .firstWhere((e) => describeEnum(e) == textSize.split(':').first);
      var value = double.parse(textSize.split(':').last);
      motif.sizeMap[key] = value;
    }

    activeMotif = motif;
    return motif;
  }

  static TextStyle getStyle(Fonts font, Sizes size, Color color) => TextStyle(
        fontFamily: activeMotif.fontMap[font],
        fontSize: activeMotif.sizeMap[size],
        color: color,
      );
}

class MotifColors {
  final Color title,
      template,
      thing,
      view,
      negative,
      neutral,
      positive,
      modal,
      background;

  MotifColors(
      {this.title,
      this.template,
      this.thing,
      this.view,
      this.negative,
      this.neutral,
      this.positive,
      this.modal,
      this.background});

  static MotifColors fromList(List<String> list) {
    var map = Map.fromIterable(list,
        key: (e) => TextColor.values
            .firstWhere((tc) => describeEnum(tc) == e.split(':').first),
        value: (e) => HexColor.fromHex(e.split(':').last));
    return MotifColors(
      title: map[TextColor.Title],
      template: map[TextColor.Template],
      thing: map[TextColor.Thing],
      view: map[TextColor.View],
      negative: map[TextColor.Negative],
      neutral: map[TextColor.Neutral],
      positive: map[TextColor.Positive],
      modal: map[TextColor.Modal],
      background: map[TextColor.Background],
    );
  }

  List<String> toList() {
    return TextColor.values.map<String>((e) {
      Color value;
      switch (e) {
        case TextColor.Title:
          value = title;
          break;
        case TextColor.Template:
          value = template;
          break;
        case TextColor.Thing:
          value = thing;
          break;
        case TextColor.View:
          value = view;
          break;
        case TextColor.Negative:
          value = negative;
          break;
        case TextColor.Neutral:
          value = neutral;
          break;
        case TextColor.Positive:
          value = positive;
          break;
        case TextColor.Modal:
          value = modal;
          break;
        case TextColor.Background:
          value = background;
          break;
      }
      return "${describeEnum(e)}:${value.toHex()}";
    }).toList();
  }
}
