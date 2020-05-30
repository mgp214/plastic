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
    if (token.isEmpty) {
      try {
        token = (await SharedPreferences.getInstance()).getString("token");
      } on Exception {
        throw new Exception("Couldn't get logged in user. Please log in.");
      }
    }
    _templates..addAll(await BackendService.getTemplatesByUser(token));
  }

  Template getTemplate(String fullName) {
    return _templates.firstWhere(
      (t) => t.name == fullName,
      orElse: () => null,
    );
  }

  List<Template> getTemplateMatches(String partial) {
    return _templates.where((t) => t.name.indexOf(partial) != -1);
  }
}
