import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';

class ConditionCard extends StatelessWidget {
  final List<Widget> children;
  final String label;

  const ConditionCard({Key key, @required this.children, @required this.label})
      : super(key: key);
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Card(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Motif.contentStyle(Sizes.Content, Motif.neutral),
                    ),
                    ...children
                  ],
                ),
              ),
              Icon(
                Icons.menu,
                color: Motif.neutral,
              ),
            ],
          ),
        ),
      );
}
