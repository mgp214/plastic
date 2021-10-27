import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/view/view_widgets/simple_list_widget.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';
import 'package:plastic/widgets/thing/edit_thing_page.dart';

class SimpleListWidgetWidget extends StatelessWidget {
  final SimpleListWidget simpleListWidget;

  const SimpleListWidgetWidget({Key key, @required this.simpleListWidget})
      : super(key: key);

  List<Widget> _getThingWidgets(BuildContext context) {
    var widgets = new List<Widget>();
    if (simpleListWidget.things is String) {
      widgets.add(
        Center(
          child: Text(
            simpleListWidget.things.toString(),
            style: Motif.headerStyle(Sizes.Header, Motif.title),
          ),
        ),
      );
    } else if (simpleListWidget.things is List<Thing>) {
      for (var thing in simpleListWidget.things) {
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
                ).then((val) => simpleListWidget.getData()),
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
    } else {
      log("simpleListWidget things is null");
      simpleListWidget
          .getData()
          .then((value) => simpleListWidget.triggerRebuild());
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: _getThingWidgets(context),
      );
}
