import 'package:plastic/api/backend_service.dart';
import 'package:plastic/model/template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemplateManager {
  static final TemplateManager _singleton = TemplateManager._internal();

  factory TemplateManager() {
    return _singleton;
  }

  TemplateManager._internal();

  final List<Template> _templates = new List<Template>();
  String token;

  Future<void> loadTemplates() async {
    if (token == null || token.isEmpty) {
      try {
        token = (await SharedPreferences.getInstance()).getString("token");
      } on Exception {
        throw new Exception("Couldn't get logged in user. Please log in.");
      }
    }
    _templates..addAll(await BackendService.getTemplatesByUser(token));
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

  List<Template> getAllTemplates() => _templates.toList();

  List<Template> getTemplateMatches(String partial) => _templates
      .where(
        (t) => t.name.toLowerCase().indexOf(partial.toLowerCase()) != -1,
      )
      .toList();
}
