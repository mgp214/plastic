import 'package:flutter/material.dart';
import 'package:plastic/utility/style.dart';

class AutocompleteListWidget extends StatelessWidget {
  final Map<String, VoidCallback> options;

  AutocompleteListWidget({@required this.options});

  @override
  Widget build(BuildContext context) {
    var sortedOptions = options.entries.toList();
    sortedOptions.sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      padding: EdgeInsets.zero,
      children: sortedOptions
          .map((option) => FlatButton(
                padding: EdgeInsets.zero,
                child: Text(
                  option.key,
                  style: Style.getStyle(
                    FontRole.Content,
                    Style.accent,
                  ),
                ),
                onPressed: option.value,
              ))
          .toList(),
    );
  }
}
