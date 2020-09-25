import 'package:flutter/material.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';

import 'edit_thing_widget.dart';

class ViewAllThingsWidget extends StatelessWidget {
  final List<Thing> things;
  final VoidCallback onRefresh;

  ViewAllThingsWidget({@required this.things, @required this.onRefresh})
      : super();

  List<Widget> _getThingWidgets(context) {
    var widgets = new List<Widget>();
    if (things.length == 0)
      widgets.add(
        Container(
          padding: EdgeInsets.all(15),
          child: Text(
            "No things to see here.",
            style: Style.getStyle(
              FontRole.Content,
              Style.primary,
            ),
          ),
        ),
      );
    for (var thing in things) {
      widgets.add(
        SplashListTile(
          color: Style.accent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditThingWidget(
                template: TemplateManager().getTemplateById(thing.templateId),
                thing: thing,
              ),
            ),
          ).then((val) => onRefresh()),
          child: Text(
            thing.getMainField().value ?? "???",
            style: Style.getStyle(
              FontRole.Display3,
              Style.primary,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        backgroundColor: Style.background,
        color: Style.accent,
        child: ListView(
          children: _getThingWidgets(context),
        ),
      );
}
