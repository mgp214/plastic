import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:plastic/model/api/log_in_response.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  // static final String _root = 'http://66.175.219.233:8080/';
  static final String _root = 'http://10.0.2.2:8080/';
  static final routes = <String, String>{
    "register": _root + 'users',
    "login": _root + "users/login",
    "checkToken": _root + "users/checktoken",
    "logout": _root + "users/me/logout",
    "logoutAll": _root + "users/me/logoutall",
    "templatesByUser": _root + "templates/all",
    "templateById": _root + "templates/",
  };

  /// Attempts to log in with the given credentials. Returns a token if successful, otherwise throws an exception.
  static Future<LogInResponse> login(String email, String password) async {
    final response = await http.post(
      routes["login"],
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
      routes["register"],
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
      routes["checkToken"],
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
  static Future<Null> logout(String token) async {
    await clearPrefs();
    final response = await http.post(
      routes["logout"],
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
  static Future<Null> logoutAll(String token) async {
    await clearPrefs();
    final response = await http.post(
      routes["logoutAll"],
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
  static Future<Template> getTemplateById(
      String token, String templateId) async {
    final response = await http.get(
      routes['templateById'] + templateId,
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
  static Future<List<Template>> getTemplatesByUser(String token) async {
    final response = await http.get(
      routes['templatesByUser'],
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
}
