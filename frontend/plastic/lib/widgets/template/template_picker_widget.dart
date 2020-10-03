import 'package:flutter/material.dart';
import 'package:objectid/objectid.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';
import 'package:plastic/widgets/template/edit_template_widget.dart';
import 'package:plastic/widgets/thing/edit_thing_widget.dart';

class TemplatePickerWidget extends StatefulWidget {
  final List<Template> templates;

  TemplatePickerWidget({this.templates}) : super();

  @override
  State<StatefulWidget> createState() => TemplatePickerState();
}

class TemplatePickerState extends State<TemplatePickerWidget> {
  @override
  Widget build(BuildContext context) => Material(
        color: Motif.background,
        child: ListView(
          children: _getChildren(),
        ),
      );

  List<Widget> _getChildren() {
    List children = widget.templates
        .map<Widget>(
          (template) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Card(
              elevation: 5,
              color: Motif.lightBackground,
              child: SplashListTile(
                color: Motif.title,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditThingWidget(
                      template: template,
                      thing: Thing(
                        templateId: template.id,
                        userId: template.userId,
                      ),
                    ),
                  ),
                ),
                child: Text(template.name,
                    style: Motif.contentStyle(
                      Sizes.Action,
                      Motif.black,
                    )),
              ),
            ),
          ),
        )
        .toList();
    children.add(
      BorderButton(
        content: "Create a new template",
        color: Motif.neutral,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTemplateWidget(
              template: Template(
                  id: ObjectId().hexString,
                  fields: [],
                  userId: Api.account.getUserId()),
            ),
          ),
        ),
      ),
    );
    return children;
  }
}
