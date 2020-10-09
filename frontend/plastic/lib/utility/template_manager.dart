import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';

class TemplateManager {
  static final TemplateManager _singleton = TemplateManager._internal();

  factory TemplateManager() {
    return _singleton;
  }

  bool needsToReload;

  TemplateManager._internal() {
    needsToReload = true;
  }

  final List<Template> _templates = new List<Template>();

  Future<void> loadTemplates(BuildContext context) async {
    var response = await Api.template.getTemplatesByUser(context);
    _templates
      ..clear()
      ..addAll(response.getResult);
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

  bool doesTemplateExist(String templateId) {
    return _templates.indexWhere((t) => t.id == templateId) != -1;
  }

  List<Template> getAllTemplates() {
    return _templates.toList();
  }

  Future<void> loadTemplatesIfNeeded(BuildContext context) async {
    if (needsToReload) {
      await loadTemplates(context);
      needsToReload = false;
    }
  }

  bool hasTemplates() => _templates.length > 0;

  List<Template> getTemplateMatches(String partial) => _templates
      .where(
        (t) => t.name.toLowerCase().indexOf(partial.toLowerCase()) != -1,
      )
      .toList();
}
