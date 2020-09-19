import 'package:flutter/material.dart';
import 'package:plastic/api/backend_service.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/utility/template_manager.dart';

import 'edit_thing_widget.dart';

class ViewAllThingsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ViewAllThingsState();
}

class ViewAllThingsState extends State<ViewAllThingsWidget> {
  List<Thing> _things = List<Thing>();

  ViewAllThingsState() {
    BackendService.getThingsByUser().then(
      (value) => setState(
        () => {
          _things = value,
        },
      ),
    );
  }

  List<Widget> _getThingWidgets() {
    var widgets = new List<Widget>();
    if (_things.length == 0) widgets.add(Text("Nothing to see here."));
    for (var thing in _things) {
      widgets.add(
        InkWell(
          splashColor: Style.accent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditThingWidget(
                template: TemplateManager().getTemplateById(thing.templateId),
                thing: thing,
              ),
            ),
          ),
          child: ListTile(
            title: Text(
              thing.getMainField().value ?? "???",
              style: Style.getStyle(
                FontRole.Content,
                Style.primary,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: _getThingWidgets(),
      );
}
