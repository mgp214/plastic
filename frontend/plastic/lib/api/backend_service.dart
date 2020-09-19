import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:plastic/model/api/log_in_response.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Routes {
  register,
  login,
  checkToken,
  logout,
  logoutAll,
  templatesByUser,
  templateById,
  saveThing,
  thingsByUser,
}

class BackendService {
  // static final String _root = 'http://66.175.219.233:8080/';
  static final String _root = 'http://10.0.2.2:8080/';

  static String getRoute(Routes route) {
    String value;
    switch (route) {
      case Routes.register:
        value = _root + 'users';
        break;
      case Routes.login:
        value = _root + "users/login";
        break;
      case Routes.checkToken:
        value = _root + "users/checktoken";
        break;
      case Routes.logout:
        value = _root + "users/me/logout";
        break;
      case Routes.logoutAll:
        value = _root + "users/me/logoutall";
        break;
      case Routes.templatesByUser:
        value = _root + "templates/all";
        break;
      case Routes.templateById:
        value = _root + "templates/";
        break;
      case Routes.saveThing:
        value = _root + "things/create";
        break;
      case Routes.thingsByUser:
        value = _root + "things/all";
        break;
    }
    return value;
  }

  static String token;

  /// Attempts to log in with the given credentials. Returns a token if successful, otherwise throws an exception.
  static Future<LogInResponse> login(String email, String password) async {
    final response = await http.post(
      getRoute(Routes.login),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        "email": email.trim(),
        "password": password,
      }),
    );
    if (response.statusCode != 200) {
      throw new HttpException(json.decode(response.body)['error']);
    }
    var loginResponse = new LogInResponse.fromJson(json.decode(response.body));
    TemplateManager().loadTemplates();
    return loginResponse;
  }

  /// Register a new user
  static Future<LogInResponse> register(
      String email, String password, String name) async {
    final response = await http.post(
      getRoute(Routes.register),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        "email": email.trim(),
        "name": name.trim(),
        "password": password,
      }),
    );
    if (response.statusCode != 201) {
      throw new HttpException(json.decode(response.body)['error']);
    }
    return new LogInResponse.fromJson(json.decode(response.body));
  }

  /// Check if a given token is valid
  static Future<bool> checkToken(String token) async {
    if (token == null) return false;

    final response = await http.post(
      getRoute(Routes.checkToken),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({"token": token}),
    );

    if (response.statusCode != 200)
      throw new HttpException(json.decode(response.body)['error']);

    var result = "true" == response.body;
    if (result) TemplateManager().loadTemplates();

    return "true" == response.body;
  }

  /// Log out just this token
  static Future<Null> logout() async {
    await _fetchToken();
    await clearPrefs();
    final response = await http.post(
      getRoute(Routes.logout),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw new HttpException(json.decode(response.body)['error']);
    }
  }

  /// Log out all tokens
  static Future<Null> logoutAll() async {
    await _fetchToken();
    await clearPrefs();
    final response = await http.post(
      getRoute(Routes.logoutAll),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw new HttpException(json.decode(response.body)['error']);
    }
  }

  /// Clear out any saved user information from persistent storage
  static Future clearPrefs() async {
    var preferences = await SharedPreferences.getInstance();
    for (var key in ["token", "name", "email", 'id']) {
      if (preferences.containsKey(key)) preferences.remove(key);
    }
  }

  /// Get a single template by id.
  static Future<Template> getTemplateById(String templateId) async {
    await _fetchToken();
    final response = await http.get(
      getRoute(Routes.templateById) + templateId,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw new HttpException(json.decode(response.body)['error']);
    }
    return new Template.fromJson(json.decode(response.body));
  }

  /// Get all of a User's templates.
  static Future<List<Template>> getTemplatesByUser() async {
    await _fetchToken();
    final response = await http.get(
      getRoute(Routes.templatesByUser),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw new HttpException(json.decode(response.body)['error']);
    }
    var templates = new List<Template>();
    json
        .decode(response.body)
        .forEach((v) => templates.add(new Template.fromJson(v)));
    return templates;
  }

  /// Get all of a User's things.
  static Future<List<Thing>> getThingsByUser() async {
    await _fetchToken();
    final response = await http.get(
      getRoute(Routes.thingsByUser),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw new HttpException(json.decode(response.body)['error']);
    }
    var things = new List<Thing>();
    json
        .decode(response.body)
        .forEach((v) => things.add(new Thing.fromJsonMap(v)));
    return things;
  }

  static Future<http.Response> saveThing(Thing thing) async {
    await _fetchToken();
    final response = await http.post(
      getRoute(Routes.saveThing),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: thing.toJson(),
    );
    return response;
  }

  static Future<void> _fetchToken() async {
    if (token == null) {
      try {
        token = (await SharedPreferences.getInstance()).getString("token");
      } on Exception {
        token = null;
        throw new Exception("Couldn't get logged in user. Please log in.");
      }
    }
  }
}
