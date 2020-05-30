import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/action_menu/autocomplete_list_widget.dart';

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
  OverlayEntry _templateAutocompleteOverlay;
  TextEditingController _controller;

  Map<String, VoidCallback> onTemplateAutocompleted(
      List<Template> partialMatches, RegExpMatch r, String text) {
    var options = Map<String, VoidCallback>();
    partialMatches.forEach((match) {
      options[match.name] = () {
        _templateAutocompleteOverlay.remove();
        _templateAutocompleteOverlay = null;

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
      };
    });

    return options;
  }

  void onChanged(BuildContext context, String newValue) {
    // old regex:#['\"](\\w+)
    var regExpMatch = RegExp(
            "((?:(?<=#['\"])[a-zA-Z0-9\-_ ]+['\"]*?)|(?:(?<=#)[a-zA-Z0-9\-_]+))")
        .firstMatch(newValue.toLowerCase());
    if (regExpMatch == null) return;
    String templateMatch = regExpMatch.group(1);
    if (templateMatch.isEmpty) {
      removeOverlay(_templateAutocompleteOverlay);
    }

    template = TemplateManager().getTemplate(templateMatch);
    if (template == null) {
      var partialMatches = TemplateManager().getTemplateMatches(templateMatch);

      var options =
          onTemplateAutocompleted(partialMatches, regExpMatch, newValue);

      showAutocomplete(
          context, newValue.substring(0, regExpMatch.start - 1), options);
      return;
    }
    removeOverlay(_templateAutocompleteOverlay);

    //TODO: Pull up template as model, search for other field names, If partial, show partial matches as dropdown options
  }

  void removeOverlay(OverlayEntry overlay) {
    if (overlay != null) {
      overlay.remove();
      overlay = null;
    }
  }

  Future<void> showAutocomplete(BuildContext context, String text,
      Map<String, VoidCallback> options) async {
    var quickAddContentPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(style: _textStyle, text: text),
    );

    quickAddContentPainter.layout();

    removeOverlay(_templateAutocompleteOverlay);

    if (options.length == 0) {
      options["<no matches>"] = null;
    }

    String longestOption = "";
    options.keys.forEach((element) {
      if (element.length > longestOption.length) longestOption = element;
    });

    //build a painter to find the width of the overlay
    var optionsPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(style: _textStyle, text: longestOption),
    );
    optionsPainter.layout();

    var height = Math.min(options.keys.length * 60.0, 174.0);

    var overlayState = Overlay.of(context);
    _templateAutocompleteOverlay = OverlayEntry(
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

    overlayState.insert(_templateAutocompleteOverlay);

    // await Future.delayed(Duration(milliseconds: 500));
    // overlayEntry.remove();
  }

  @override
  void initState() {
    super.initState();
    workingThing = new Map<String, dynamic>();
    _textStyle = Style.getStyle(FontRole.Content, Style.accent);
    _controller = TextEditingController();
    widget.focusNode.addListener(() {
      if (!widget.focusNode.hasFocus)
        removeOverlay(_templateAutocompleteOverlay);
    })
        // _controller = TextEditingController();
        // ..addListener(() => onChanged(context, _controller.text));
        ;
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
}
