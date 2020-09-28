import 'package:flutter/material.dart';
import 'package:objectid/objectid.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';
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
        color: Style.background,
        child: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: ListView(
            children: _getChildren(),
          ),
        ),
      );

  List<Widget> _getChildren() {
    var children = widget.templates
        .map(
          (template) => SplashListTile(
            color: Style.accent,
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
                style: Style.getStyle(
                  FontRole.Display3,
                  Style.primary,
                )),
          ),
        )
        .toList();
    children.add(
      SplashListTile(
        color: Style.accent,
        onTap: () => Navigator.push(
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
        child: Text("Create a new template",
            style: Style.getStyle(FontRole.Display3, Style.accent)),
      ),
    );
    return children;
  }
}
