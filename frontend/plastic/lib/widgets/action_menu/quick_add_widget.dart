import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/utility/text_utilities.dart';
import 'package:plastic/widgets/action_menu/autocomplete_list_widget.dart';

typedef void BuildOverlay(String before, String match, String after);

class QuickAddWidget extends StatefulWidget {
  final FocusNode focusNode;

  QuickAddWidget({this.focusNode});

  @override
  State<StatefulWidget> createState() => QuickAddState();
}

class QuickAddState extends State<QuickAddWidget> {
  Map<String, dynamic> workingThing;
  Template template;

  TextStyle _textStyle;
  List<OverlayEntry> _mountedOverlays;
  Map<String, BuildOverlay> overlayBuildMap;
  String previousText;

  TextEditingController _controller;

  /// Called whenever the quickAdd text has changed.
  void onChanged(BuildContext context, String newValue) {
    _updateOverlays();
    previousText = newValue;
  }

  /// Removes all overlays and rebuilds those that are still valid.
  void _updateOverlays() {
    var quickAddFullText = _controller.text;

    var textChange = getTextChangeDetails(previousText, quickAddFullText);
    var shouldAutocomplete = textChange.type == TextChangeType.Added &&
            textChange.difference == ' ' ||
        textChange.difference == '\t';
    _clearOverlays();
    buildTemplateOverlay(
      quickAddFullText,
      RegExp(
          "((?:(?<=#['\"])[a-zA-Z0-9\-_ ]+['\"]*?)|(?:(?<=#)[a-zA-Z0-9\-_]+))"),
      shouldAutocomplete,
    );

    //TODO: Pull up template as model, search for other field names, If partial, show partial matches as dropdown options
  }

  /// Tracks and displays an overlay.
  void _insertOverlay(OverlayEntry overlay) {
    Overlay.of(context).insert(overlay);
    _mountedOverlays.add(overlay);
  }

  /// Clears all tracked overlays.
  void _clearOverlays() {
    for (var overlay in _mountedOverlays) {
      overlay.remove();
    }
    _mountedOverlays.clear();
  }

  @override
  void initState() {
    super.initState();
    workingThing = new Map();
    _textStyle = Style.getStyle(FontRole.Content, Style.accent);
    _controller = TextEditingController();
    _mountedOverlays = new List();
    overlayBuildMap = new Map();
    previousText = '';
    widget.focusNode.addListener(() {
      if (!widget.focusNode.hasFocus) _clearOverlays();
    });
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: MediaQuery.of(context).size.width - 75,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Style.borderRadius),
              border: Border.all(color: Style.primary),
              color: Style.inputField),
          padding: EdgeInsets.all(1),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 200,
            ),
            child: TextField(
              focusNode: widget.focusNode,
              decoration:
                  InputDecoration(border: InputBorder.none, filled: false),
              style: _textStyle,
              onChanged: (text) => onChanged(context, text),
              controller: _controller,
              maxLines: null,
            ),
          ),
        ),
      );

  /// Builds the template overlay, if applicable.
  void buildTemplateOverlay(String text, RegExp r, bool shouldAutocomplete) {
    var match;
    if (shouldAutocomplete)
      match = r.firstMatch(previousText.toLowerCase());
    else
      match = r.firstMatch(text.toLowerCase());

    if (match == null) return;

    var before = text.substring(0, match.start);
    var matchText = match.group(1);
    var after = text.substring(match.end);

    var template = TemplateManager().getTemplate(matchText);
    if (template != null) return;

    var partialTemplateMatches =
        TemplateManager().getTemplateMatches(matchText);

    var options = buildTemplateOptions(partialTemplateMatches, match, text);
    if (shouldAutocomplete && partialTemplateMatches.length == 1) {
      options[partialTemplateMatches.first.name]();
      return;
    }

    // Calculate where to show the overlay
    var quickAddContentPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(style: _textStyle, text: before),
    );

    quickAddContentPainter.layout();

    if (options.length == 0) {
      options["<no matches>"] = null;
    }

    // figure out the max length of our options
    String longestOption = "";
    options.keys.forEach((element) {
      if (element.length > longestOption.length) longestOption = element;
    });

    //build a painter to find the width of the overlay, based on longest option
    var optionsPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(style: _textStyle, text: longestOption),
    );
    optionsPainter.layout();

    var height = Math.min(options.keys.length * 60.0, 174.0);

    var templateOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: widget.focusNode.offset.dy - height,
        left: widget.focusNode.offset.dx + quickAddContentPainter.width,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: optionsPainter.width + 50,
            height: height,
            child: Material(
              color: Style.background,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutocompleteListWidget(
                  options: options,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _insertOverlay(templateOverlay);
  }

  /// Builds a list of matching templates with onSelected functions.
  Map<String, VoidCallback> buildTemplateOptions(
      List<Template> partialMatches, RegExpMatch r, String text) {
    var options = Map<String, VoidCallback>();
    partialMatches.forEach((match) {
      options[match.name] = () {
        var addLeadingSpace = '';
        var matchString = text.substring(r.start, r.end);
        var checkForLeadingSpaceRegExp = RegExp("( (?=#))").firstMatch(text);
        var replacementStartRegExp = RegExp("#").firstMatch(text);
        if (checkForLeadingSpaceRegExp == null) addLeadingSpace = ' ';
        var addTrailingSpace = r.end == text.length ||
                (text[r.end] != ' ' &&
                    (text[r.end] == '\'' || text[r.end] == '\"'))
            ? ' '
            : '';

        var addQuotes = match.name.indexOf(' ') != -1 ? '\'' : '';

        var subtituteString = addLeadingSpace +
            '#' +
            addQuotes +
            match.name +
            addQuotes +
            addTrailingSpace;

        var replacementString = text.replaceRange(
          replacementStartRegExp.start,
          r.end,
          subtituteString,
        );

        var cursorPosition =
            replacementStartRegExp.start + subtituteString.length;

        setState(
          () => {
            _controller.text = replacementString,
            _controller.selection = TextSelection(
                baseOffset: cursorPosition, extentOffset: cursorPosition)
          },
        );

        _updateOverlays();
      };
    });

    return options;
  }
}
