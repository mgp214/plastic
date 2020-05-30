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

  TextStyle _textStyle;
  OverlayEntry _templateAutocompleteOverlay;
  TextEditingController _controller;

  void onChanged(BuildContext context, String newValue) {
    var regExpMatch = RegExp(r"#(\w+)").firstMatch(newValue.toLowerCase());
    if (regExpMatch == null) return;
    String templateMatch = regExpMatch.group(1);
    if (templateMatch.isEmpty) return;

    Template template = TemplateManager().getTemplate(templateMatch);
    if (template == null) {
      var partialMatches = TemplateManager().getTemplateMatches(templateMatch);

      var options = Map<String, VoidCallback>();
      partialMatches.forEach(
        (match) {
          options[match.name] = () {
            _templateAutocompleteOverlay.remove();
            _templateAutocompleteOverlay = null;

            var addLeadingSpace =
                regExpMatch.start > 0 && newValue[regExpMatch.start - 1] != ' '
                    ? ' '
                    : '';
            var addTrailingSpace = regExpMatch.end == newValue.length ||
                    newValue[regExpMatch.end] != ' '
                ? ' '
                : '';

            var replacementString = newValue.replaceRange(
                regExpMatch.start,
                regExpMatch.end,
                addLeadingSpace + '#' + match.name + addTrailingSpace);
            setState(
              () => {
                _controller.text = replacementString,
              },
            );
          };
        },
      );

      showAutocomplete(
          context, newValue.substring(0, regExpMatch.start - 1), options);
    } else {
      _templateAutocompleteOverlay.remove();
      _templateAutocompleteOverlay = null;
    }

    //TODO: Pull up template as model, search for other field names, If partial, show partial matches as dropdown options
  }

  Future<void> showAutocomplete(BuildContext context, String text,
      Map<String, VoidCallback> options) async {
    var quickAddContentPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(style: _textStyle, text: text),
    );

    quickAddContentPainter.layout();

    if (_templateAutocompleteOverlay != null) {
      _templateAutocompleteOverlay.remove();
      _templateAutocompleteOverlay = null;
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

    var height = Math.min(options.keys.length * 58.0, 174.0);

    var overlayState = Overlay.of(context);
    _templateAutocompleteOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: widget.focusNode.offset.dy - height,
        left: widget.focusNode.offset.dx + quickAddContentPainter.width,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            width: optionsPainter.width + 50,
            height: height,
            child: Material(
              color: Style.background,
              child: Align(
                alignment: Alignment.bottomCenter,
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
