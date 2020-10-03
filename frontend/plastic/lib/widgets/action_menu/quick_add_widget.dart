// import 'dart:math' as Math;

// import 'package:flutter/material.dart';
// import 'package:plastic/model/template.dart';
// import 'package:plastic/model/thing.dart';
// import 'package:plastic/model/motif.dart';
// import 'package:plastic/utility/template_manager.dart';
// import 'package:plastic/utility/text_utilities.dart';
// import 'package:plastic/widgets/action_menu/autocomplete_list_widget.dart';

// typedef void BuildOverlay(String before, String match, String after);

// class QuickAddWidget extends StatefulWidget {
//   final FocusNode focusNode;

//   QuickAddWidget({this.focusNode});

//   @override
//   State<StatefulWidget> createState() => QuickAddState();
// }

// class QuickAddState extends State<QuickAddWidget> {
//   static const String FIELD_REGEX =
//       "((?:(?<=['\"])[\\w- _]+(?=['\"]:))|(?:[\\w-_]+(?=:)))";
//   static const String TEMPLATE_REGEX =
//       "((?:(?<=#['\"])[\\w-_ ]+['\"]*?)|(?:(?<=#)[\\w-_]+))";
//   Thing workingThing;
//   Template _template;

//   TextStyle _textStyle;
//   List<OverlayEntry> _mountedOverlays;
//   Map<String, BuildOverlay> overlayBuildMap;
//   String previousText;

//   TextEditingController _controller;

//   /// Called whenever the quickAdd text has changed.
//   void onChanged(BuildContext context, String newValue) {
//     _updateOverlays();
//     previousText = newValue;
//   }

//   /// Removes all overlays and rebuilds those that are still valid.
//   void _updateOverlays() {
//     var quickAddFullText = _controller.text;

//     // var textChange = getTextChangeDetails(previousText, quickAddFullText);
//     // var shouldAutocomplete = textChange.type == TextChangeType.Added &&
//     //         textChange.difference == ' ' ||
//     //     textChange.difference == '\t';
//     _clearOverlays();

//     _template = updateTemplate(quickAddFullText);
//     // buildTemplateOverlay(
//     //   quickAddFullText,
//     //   RegExp(TEMPLATE_REGEX),
//     //   shouldAutocomplete,
//     // );

//     if (_template == null) return;

//     var cursorWord = _getCursorWord();

//     var partialMatchingFields = _template.getFieldsByPartial(cursorWord.match);

//     var options = Map<String, VoidCallback>();
//     partialMatchingFields.forEach((element) {
//       options[element.name] = () => print(element.name);
//     });

//     buildOverlay(quickAddFullText, cursorWord.start, options);

//     // workingThing = buildWorkingThing(quickAddFullText, shouldAutocomplete);

//     // // find if cursor is touching partial field match

//     // var whitespaceRegex = RegExp('\\s');
//     // var cursorPosition = _controller.selection.start;
//     // var cursorWordStart = cursorPosition;
//     // var cursorWordEnd = cursorPosition;
//     // while (cursorWordStart > 0 &&
//     //     !whitespaceRegex.hasMatch(_controller.text[cursorWordStart - 1]))
//     //   cursorWordStart--;
//     // while (cursorWordEnd < _controller.text.length &&
//     //     !whitespaceRegex.hasMatch(_controller.text[cursorWordStart + 1]))
//     //   cursorWordEnd++;
//     // var cursorWord = _controller.text.substring(cursorWordStart, cursorWordEnd);

//     // var fieldOptions = new Map<String, VoidCallback>();
//     // for (var field in _template.fields) {
//     //   if (field.name.toLowerCase().indexOf(cursorWord.toLowerCase()) == -1)
//     //     continue;
//     //   fieldOptions[field.name] = () {
//     //     print(field.name);
//     //   };
//     // }

//     // buildOverlay(
//     //     _controller.text, cursorWordStart, fieldOptions, shouldAutocomplete);
//   }

//   TextMatch _getCursorWord() {
//     var whitespaceRegex = RegExp('\\s');
//     var cursorPosition = _controller.selection.start;
//     var cursorWordStart = cursorPosition;
//     var cursorWordEnd = cursorPosition;
//     while (cursorWordStart > 0 &&
//         !whitespaceRegex.hasMatch(_controller.text[cursorWordStart - 1]))
//       cursorWordStart--;
//     while (cursorWordEnd < _controller.text.length &&
//         !whitespaceRegex.hasMatch(_controller.text[cursorWordStart + 1]))
//       cursorWordEnd++;
//     var cursorWord = _controller.text.substring(cursorWordStart, cursorWordEnd);

//     return TextMatch(
//       start: cursorWordStart,
//       end: cursorWordEnd,
//       match: cursorWord,
//     );
//   }

//   Template updateTemplate(String text) {
//     var r = RegExp(TEMPLATE_REGEX);
//     if (r.hasMatch(text)) {
//       var matches = r.allMatches(text);
//       // if we only have a single match, and it's a perfect match, that's our selected template.
//       if (matches.length == 1 &&
//           TemplateManager().getTemplateByName(matches.first.group(0)) != null)
//         return TemplateManager().getTemplateByName(matches.first.group(0));

//       buildTemplateOverlay(text, r);
//     }

//     // unless we had a perfect match, don't return a valid template.
//     return null;
//   }

//   Thing buildWorkingThing(String quickAddText, bool shouldAutocomplete) {
//     workingThing = new Thing(templateId: _template.id);

//     // find all completed template fields.
//     var completedFieldRegex = RegExp(FIELD_REGEX);
//     var matches = completedFieldRegex.allMatches(quickAddText).toList();
//     if (matches.length > 0) {
//       for (var matchIndex = 0; matchIndex < matches.length; matchIndex++) {
//         var match = matches[matchIndex];
//         //TODO: format valid fields
//         var fieldIndex = _template.fields
//             .indexWhere((field) => field.name == match.group(1));
//         if (fieldIndex != -1) {
//           var fieldValue = matchIndex == matches.length - 1
//               ? quickAddText.substring(match.end)
//               : quickAddText.substring(
//                   match.end, matches[matchIndex + 1].start - 1);

//           //skip forward past any closing quote and ':'s
//           var cleanupRegex = new RegExp('^[\'"]*:');
//           var cleanupMatch = cleanupRegex.firstMatch(fieldValue);
//           if (cleanupMatch != null) {
//             fieldValue = fieldValue.substring(cleanupMatch.end);
//           }

//           workingThing.fields[fieldIndex].value = fieldValue;
//         }
//       }
//     }

//     return workingThing;
//   }

//   /// Tracks and displays an overlay.
//   void _insertOverlay(OverlayEntry overlay) {
//     Overlay.of(context).insert(overlay);
//     _mountedOverlays.add(overlay);
//   }

//   /// Clears all tracked overlays.
//   void _clearOverlays() {
//     for (var overlay in _mountedOverlays) {
//       overlay.remove();
//     }
//     _mountedOverlays.clear();
//   }

//   /// Builds the template overlay, if applicable.
//   void buildTemplateOverlay(String text, RegExp r) {
//     // var match;
//     // if (shouldAutocomplete)
//     //   match = r.firstMatch(previousText.toLowerCase());
//     // else
//     //   match = r.firstMatch(text.toLowerCase());
//     // if (match == null) return;
//     var match = r.firstMatch(text.toLowerCase());
//     // var before = text.substring(0, match.start);
//     // var matchText = match.group(1);
//     // var after = text.substring(match.end);

//     // _template = TemplateManager().getTemplate(matchText);
//     // if (_template != null) return;

//     var partialTemplateMatches =
//         TemplateManager().getTemplateMatches(match.group(1));

//     var options = buildTemplateOptions(partialTemplateMatches, match, text);
//     // if (shouldAutocomplete && partialTemplateMatches.length == 1) {
//     //   options[partialTemplateMatches.first.name]();
//     //   return;
//     // }

//     buildOverlay(text, match.start, options);
//   }

//   /// Build and display an autocomplete overlay
//   void buildOverlay(
//       String fullText, int startIndex, Map<String, VoidCallback> options) {
//     // if user has spaced away from a single-match overlay, auto-select only match
//     // if (shouldAutocomplete && options.length == 1) {
//     //   options.values.first();
//     //   return;
//     // }

//     // Calculate where to show the overlay
//     var quickAddContentPainter = TextPainter(
//       textDirection: TextDirection.ltr,
//       text:
//           TextSpan(style: _textStyle, text: fullText.substring(0, startIndex)),
//     );

//     quickAddContentPainter.layout();

//     if (options.length == 0) {
//       options["<no matches>"] = null;
//     }

//     // figure out the max length of our options
//     String longestOption = "";
//     options.keys.forEach((element) {
//       if (element.length > longestOption.length) longestOption = element;
//     });

//     //build a painter to find the width of the overlay, based on longest option
//     var optionsPainter = TextPainter(
//       textDirection: TextDirection.ltr,
//       text: TextSpan(style: _textStyle, text: longestOption),
//     );
//     optionsPainter.layout();

//     var height = Math.min(options.keys.length * 60.0, 174.0);

//     var templateOverlay = OverlayEntry(
//       builder: (context) => Positioned(
//         top: widget.focusNode.offset.dy - height,
//         left: widget.focusNode.offset.dx + quickAddContentPainter.width,
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: SizedBox(
//             width: optionsPainter.width + 50,
//             height: height,
//             child: Material(
//               color: Motif.background,
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: AutocompleteListWidget(
//                   options: options,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     _insertOverlay(templateOverlay);
//   }

//   /// Builds a list of matching templates with onSelected functions.
//   Map<String, VoidCallback> buildTemplateOptions(
//       List<Template> partialMatches, RegExpMatch r, String text) {
//     var options = Map<String, VoidCallback>();
//     partialMatches.forEach((match) {
//       options[match.name] = () {
//         var addLeadingSpace = '';
//         // var matchString = text.substring(r.start, r.end);
//         var checkForLeadingSpaceRegExp = RegExp("( (?=#))").firstMatch(text);
//         var replacementStartRegExp = RegExp("#").firstMatch(text);
//         if (checkForLeadingSpaceRegExp == null) addLeadingSpace = ' ';
//         var addTrailingSpace = r.end == text.length ||
//                 (text[r.end] != ' ' &&
//                     (text[r.end] == '\'' || text[r.end] == '\"'))
//             ? ' '
//             : '';

//         var addQuotes = match.name.indexOf(' ') != -1 ? '\'' : '';

//         var subtituteString = addLeadingSpace +
//             '#' +
//             addQuotes +
//             match.name +
//             addQuotes +
//             addTrailingSpace;

//         var replacementString = text.replaceRange(
//           replacementStartRegExp.start,
//           r.end,
//           subtituteString,
//         );

//         var cursorPosition =
//             replacementStartRegExp.start + subtituteString.length;

//         setState(
//           () => {
//             _controller.text = replacementString,
//             _controller.selection = TextSelection(
//                 baseOffset: cursorPosition, extentOffset: cursorPosition)
//           },
//         );

//         _updateOverlays();
//       };
//     });

//     return options;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _textStyle = Motif.contentStyle(FontRole.Content, Style.accent);
//     _controller = TextEditingController();
//     _mountedOverlays = new List();
//     overlayBuildMap = new Map();
//     previousText = '';
//     widget.focusNode.addListener(() {
//       if (!widget.focusNode.hasFocus) _clearOverlays();
//     });
//   }

//   @override
//   Widget build(BuildContext context) => Align(
//         alignment: Alignment.bottomLeft,
//         child: Container(
//           width: MediaQuery.of(context).size.width - 75,
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Constants.borderRadius),
//               border: Border.all(color: Motif.black),
//               color: Motif.lightBackground),
//           padding: EdgeInsets.all(1),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxHeight: 200,
//             ),
//             child: TextField(
//               focusNode: widget.focusNode,
//               decoration:
//                   InputDecoration(border: InputBorder.none, filled: false),
//               style: _textStyle,
//               onChanged: (text) => onChanged(context, text),
//               textInputAction: TextInputAction.done,
//               controller: _controller,
//               maxLines: null,
//             ),
//           ),
//         ),
//       );
// }
