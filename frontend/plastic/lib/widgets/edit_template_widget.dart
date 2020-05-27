import 'package:flutter/cupertino.dart';
import 'package:plastic/model/template.dart';

class EditTemplateWidget extends StatefulWidget {
  final Template template;
  EditTemplateWidget({this.template}) : super();

  @override
  State<StatefulWidget> createState() => EditTemplateState();
}

class EditTemplateState extends State<EditTemplateWidget> {
  @override
  Widget build(BuildContext context) =>
      Text(widget.template.toJson().toString());
}
