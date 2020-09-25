import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';
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
          (template) => InkWell(
            splashColor: Style.accent,
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
            child: ListTile(
              title: Text(template.name,
                  style: Style.getStyle(
                    FontRole.Display3,
                    Style.primary,
                  )),
              hoverColor: Style.accent,
              focusColor: Style.accent,
            ),
          ),
        )
        .toList();
    children.add(InkWell(
      splashColor: Style.accent,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditTemplateWidget(
            template: Template(fields: [], userId: Api.account.getUserId()),
          ),
        ),
      ),
      child: ListTile(
        title: Text("Create a new template",
            style: Style.getStyle(FontRole.Display3, Style.accent)),
        hoverColor: Style.primary,
        focusColor: Style.primary,
      ),
    ));
    return children;
  }
}
