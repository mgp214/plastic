import 'package:flutter/material.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';

import 'edit_thing_page.dart';

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
            style: Motif.contentStyle(
              Sizes.Content,
              Motif.black,
            ),
          ),
        ),
      );
    for (var thing in things) {
      widgets.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Card(
            elevation: 5,
            color: Motif.lightBackground,
            child: SplashListTile(
              color: Motif.title,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditThingPage(
                    template:
                        TemplateManager().getTemplateById(thing.templateId),
                    thing: thing,
                  ),
                ),
              ).then((val) => onRefresh()),
              child: Text(
                thing.getMainField().value ?? "???",
                style: Motif.contentStyle(
                  Sizes.Content,
                  Motif.black,
                ),
              ),
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
        backgroundColor: Motif.background,
        color: Motif.title,
        child: ListView(
          children: _getThingWidgets(context),
        ),
      );
}
