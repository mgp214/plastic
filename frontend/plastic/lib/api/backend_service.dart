import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:plastic/model/api/log_in_response.dart';

class BackendService {
  static final String _root = 'http://10.0.2.2:8080/';
  static final routes = <String, String>{
    "register": _root + 'users',
    "login": _root + "users/login",
    "checkToken": _root + "users/checktoken"
  };

  /// Attempts to log in with the given credentials. Returns a token if successful, otherwise throws an exception.
  static Future<LogInResponse> logIn(String email, String password) async {
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
    return new LogInResponse.fromJson(json.decode(response.body));
  }

  // Register a new user
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

  //Check if a given token is valid
  static Future<bool> checkToken(String token) async {
    if (token == null) return false;

    final response = await http.post(
      routes["checkToken"],
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({"token": token}),
    );

    if (response.statusCode != 200)
      throw new HttpException(json.decode(response.body)['error']);

    return "true" == response.body;
  }
}
