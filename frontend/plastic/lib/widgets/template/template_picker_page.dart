import 'package:flutter/material.dart';
import 'package:objectid/objectid.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';
import 'package:plastic/widgets/template/edit_template_page.dart';
import 'package:plastic/widgets/thing/edit_thing_page.dart';

class TemplatePickerPage extends StatefulWidget {
  TemplatePickerPage() : super();

  @override
  State<StatefulWidget> createState() => TemplatePickerPageState();
}

class TemplatePickerPageState extends State<TemplatePickerPage> {
  List<Template> _templates;
  bool _isLoaded;

  TemplatePickerPageState();

  @override
  void initState() {
    _templates = List();
    _isLoaded = false;
    super.initState();
  }

  void _loadTemplatesAndRefresh(BuildContext context) {
    TemplateManager().loadTemplatesIfNeeded(context).then((value) {
      _isLoaded = true;
      setState(() {
        _templates = TemplateManager().getAllTemplates();
      });
    });
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Motif.background,
        child: _getTemplateListView(context),
      );

  Widget _getTemplateListView(BuildContext context) {
    if (!_isLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _loadTemplatesAndRefresh(context);
      });
      return Container();
    }
    List children = _templates
        .map<Widget>(
          (template) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Card(
              elevation: 5,
              color: Motif.lightBackground,
              child: SplashListTile(
                color: Motif.title,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditThingPage(
                        template: template,
                        thing: Thing(
                          templateId: template.id,
                          userId: template.userId,
                        ),
                      ),
                    ),
                  ).then((value) => _loadTemplatesAndRefresh(context));
                },
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
            builder: (context) => EditTemplatePage(
              template: Template(
                id: ObjectId().hexString,
                fields: [],
                userId: Api.account.userId,
              ),
            ),
          ),
        ).then(
          (value) => _loadTemplatesAndRefresh(context),
        ),
      ),
    );
    return ListView(children: children);
  }
}
