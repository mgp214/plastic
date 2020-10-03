import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';

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
                  style: Motif.contentStyle(Sizes.Content, Motif.black),
                ),
                onPressed: option.value,
              ))
          .toList(),
    );
  }
}
