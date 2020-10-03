import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
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

/// Used to select colors for specific meanings
enum TextColor {
  Title,
  Negative,
  Neutral,
  Caution,
  LightBackground,
  Background,
  Black,
  White,
}

class MotifData {
  static const String FONTS_KEY = "motif.fonts";
  static const String SIZE_KEY = "motif.textSizes";
  static const String COLOR_KEY = "motif.colors";

  final Map<Fonts, String> fontMap;
  final Map<Sizes, double> sizeMap;
  final Map<TextColor, Color> colorMap;

  // final MotifColors colors;

  MotifData({this.colorMap, this.fontMap, this.sizeMap});

  static MotifData activeMotif;
  // static MotifColors getColors() => activeMotif.colors;

  static MotifData getDefault() {
    return MotifData(
      fontMap: {
        Fonts.Title: "Geo",
        Fonts.Action: "Ubuntu",
        Fonts.Header: "Ubuntu",
        Fonts.Content: "Ubuntu",
      },
      sizeMap: {
        Sizes.Title: 96,
        Sizes.Action: 28,
        Sizes.Label: 18,
        Sizes.Header: 36,
        Sizes.Content: 26,
        Sizes.Notification: 16,
      },
      colorMap: {
        TextColor.Title: HexColor.fromHex("#994C50"),
        TextColor.Negative: HexColor.fromHex("#B5696C"),
        TextColor.Black: HexColor.fromHex("#151413"),
        TextColor.White: HexColor.fromHex("#E3DEDE"),
        TextColor.Neutral: HexColor.fromHex("#968D88"),
        TextColor.LightBackground: HexColor.fromHex("#D0C8C8"),
        TextColor.Background: HexColor.fromHex("#E2DFDF"),
        TextColor.Caution: HexColor.fromHex("#B5696C"),
      },
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
    preferences.setStringList(
        COLOR_KEY,
        colorMap.entries
            .map<String>((e) => "${describeEnum(e.key)}:${e.value.toHex()}")
            .toList());

    activeMotif = this;
  }

  /// gets the cached motif, failing that loads it from preferences, failing that caches and returns the default motif
  static Future<MotifData> getMotif() async {
    if (activeMotif != null) return activeMotif;

    MotifData motifData;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // if (!preferences.containsKey(FONTS_KEY) ||
    //     !preferences.containsKey(SIZE_KEY) ||
    //     !preferences.containsKey(COLOR_KEY)) {
    // no valid motif stored in prefs, get the default motif and save it to prefs.
    motifData = getDefault();
    motifData.saveToPreferences();
    activeMotif = motifData;
    _setMotifValues(motifData);
    return motifData;
    // }

    // motif is present in prefs but is not loaded. load it and cache.

    motifData = MotifData(
      fontMap: Map(),
      sizeMap: Map(),
      colorMap: Map(),
    );
    // load text roles
    for (var font in preferences.getStringList(FONTS_KEY)) {
      var key = Fonts.values
          .firstWhere((e) => describeEnum(e) == font.split(':').first);
      var value = font.split(':').last;
      motifData.fontMap[key] = value;
    }

    // load text contexts
    for (var textSize in preferences.getStringList(SIZE_KEY)) {
      var key = Sizes.values
          .firstWhere((e) => describeEnum(e) == textSize.split(':').first);
      var value = double.parse(textSize.split(':').last);
      motifData.sizeMap[key] = value;
    }

    // load colors
    for (var color in preferences.getStringList(COLOR_KEY)) {
      var key = TextColor.values
          .firstWhere((e) => describeEnum(e) == color.split(':').first);
      var value = HexColor.fromHex(color.split(':').last);
      motifData.colorMap[key] = value;
    }

    activeMotif = motifData;
    _setMotifValues(motifData);
    return motifData;
  }

  static _setMotifValues(MotifData data) {
    Motif.title = data.colorMap[TextColor.Title];
    Motif.negative = data.colorMap[TextColor.Negative];
    Motif.caution = data.colorMap[TextColor.Caution];
    Motif.neutral = data.colorMap[TextColor.Neutral];
    Motif.background = data.colorMap[TextColor.Background];
    Motif.lightBackground = data.colorMap[TextColor.LightBackground];
    Motif.black = data.colorMap[TextColor.Black];
    Motif.white = data.colorMap[TextColor.White];
  }

  static TextStyle getStyle(Fonts font, Sizes size, Color color) => TextStyle(
        fontFamily: activeMotif.fontMap[font],
        fontSize: activeMotif.sizeMap[size],
        color: color,
      );
}
