import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plastic/api/account_api.dart';
import 'package:plastic/api/template_api.dart';
import 'package:plastic/api/thing_api.dart';

enum Routes {
  register,
  login,
  checkToken,
  logout,
  logoutAll,
  templatesByUser,
  templateById,
  saveTemplate,
  deleteTemplate,
  saveThing,
  deleteThing,
  thingsByUser,
}

class Api {
  static final String root = DotEnv().env['API_ENDPOINT'];
  static final ThingApi thing = ThingApi();
  static final TemplateApi template = TemplateApi();
  static final AccountApi account = AccountApi();

  static String getRoute(Routes route) {
    String value;
    switch (route) {
      case Routes.register:
        value = root + 'users';
        break;
      case Routes.login:
        value = root + "users/login";
        break;
      case Routes.checkToken:
        value = root + "users/checktoken";
        break;
      case Routes.logout:
        value = root + "users/me/logout";
        break;
      case Routes.logoutAll:
        value = root + "users/me/logoutall";
        break;
      case Routes.templatesByUser:
        value = root + "templates/all";
        break;
      case Routes.templateById:
        value = root + "templates/";
        break;
      case Routes.saveTemplate:
        value = root + "templates/save";
        break;
      case Routes.deleteTemplate:
        value = root + "templates/delete";
        break;
      case Routes.saveThing:
        value = root + "things/save";
        break;
      case Routes.deleteThing:
        value = root + "things/delete";
        break;
      case Routes.thingsByUser:
        value = root + "things/all";
        break;
    }
    return value;
  }
}
