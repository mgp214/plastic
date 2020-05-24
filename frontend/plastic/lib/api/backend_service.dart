import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:plastic/model/api/log_in_response.dart';

class BackendService {
  static final String root = 'http://10.0.2.2:8080';
  static final String registerRoute = root + 'users';
  static final String logInRoute = root + '/users/login';

  /// Attempts to log in with the given credentials. Returns a token if successful, otherwise throws an exception.
  static Future<LogInResponse> logIn(String email, String password) async {
    final response = await http.post(
      logInRoute,
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
}
