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
      children: sortedOptions
          .map((option) => FlatButton(
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
