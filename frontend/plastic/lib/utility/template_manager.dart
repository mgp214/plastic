import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';

class TemplateManager {
  static final TemplateManager _singleton = TemplateManager._internal();

  factory TemplateManager() {
    return _singleton;
  }

  TemplateManager._internal();

  final List<Template> _templates = new List<Template>();

  Future<void> loadTemplates(BuildContext context) async {
    if (!await Api.account.hasValidToken()) return;
    _templates.clear();
    _templates
      ..addAll((await Api.template.getTemplatesByUser(context)).getResult);
  }

  Template getTemplateByName(String fullName) {
    return _templates.firstWhere(
      (t) => t.name.toLowerCase() == fullName.toLowerCase(),
      orElse: () => null,
    );
  }

  Template getTemplateById(String templateId) {
    return _templates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => null,
    );
  }

  List<Template> getAllTemplates() {
    return _templates.toList();
  }

  Future<void> loadTemplatesIfNeeded(BuildContext context) async {
    if (_templates.length == 0) await loadTemplates(context);
  }

  bool hasTemplates() => _templates.length > 0;

  List<Template> getTemplateMatches(String partial) => _templates
      .where(
        (t) => t.name.toLowerCase().indexOf(partial.toLowerCase()) != -1,
      )
      .toList();
}
