import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/api/log_in_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountApi {
  static final AccountApi _singleton = AccountApi._internal();

  factory AccountApi() {
    return _singleton;
  }

  AccountApi._internal();

  final int _tokenCacheTtl = int.parse(DotEnv().env['TOKEN_CACHE_TTL']);
  int _tokenCacheExpirationTime = 0;
  String token;
  String _userId;

  String authHeader() => 'Bearer $token';

  String getUserId() => _userId;

  Future<bool> _fetchToken() async {
    if (token == null) {
      try {
        var preferences = await SharedPreferences.getInstance();
        token = preferences.getString("token");
        _userId = preferences.getString("id");
      } on Exception {
        token = null;
      }
    }
    return token != null;
  }

  Future<bool> hasValidToken() async {
    if (!await _fetchToken()) return false;
    if (_tokenCacheExpirationTime > DateTime.now().millisecondsSinceEpoch)
      return true;
    return await checkToken(token);
  }

  /// Attempts to log in with the given credentials. Returns a token if successful, otherwise throws an exception.
  Future<LogInResponse> login(String email, String password) async {
    final response = await http.post(
      Api.getRoute(Routes.login),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        "email": email.trim(),
        "password": password,
      }),
    );
    if (response.statusCode != 200)
      return LogInResponse(successful: false, message: response.reasonPhrase);

    var logInResponse = LogInResponse.fromJson(json.decode(response.body),
        successful: true, message: response.reasonPhrase);
    _userId = logInResponse.user.id;
    return logInResponse;
  }

  /// Register a new user
  Future<LogInResponse> register(
      String email, String password, String name) async {
    final response = await http.post(
      Api.getRoute(Routes.register),
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
    var logInResponse = new LogInResponse.fromJson(json.decode(response.body));
    _userId = logInResponse.user.id;
    return logInResponse;
  }

  /// Check if a given token is valid
  Future<bool> checkToken(String token) async {
    if (token == null) return false;

    final response = await http.post(
      Api.getRoute(Routes.checkToken),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({"token": token}),
    );

    var result = response.statusCode == 200 && "true" == response.body;

    if (!result) {
      await clearPrefs();
    } else {
      _tokenCacheExpirationTime =
          DateTime.now().millisecondsSinceEpoch + _tokenCacheTtl;
    }
    return result;
  }

  /// Log out just this token
  Future<ApiResponse> logout() async {
    if (!await _fetchToken())
      return ApiResponse(successful: false, message: 'Please log in.');
    await clearPrefs();
    final response = await http.post(
      Api.getRoute(Routes.logout),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: authHeader(),
      },
    );
    token = null;
    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }

  /// Log out all tokens
  Future<ApiResponse> logoutAll() async {
    if (!await _fetchToken())
      return ApiResponse(successful: false, message: 'Please log in.');
    await clearPrefs();
    final response = await http.post(
      Api.getRoute(Routes.logoutAll),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: authHeader(),
      },
    );
    token = null;
    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }

  /// Clear out any saved user information from persistent storage
  Future<void> clearPrefs() async {
    var preferences = await SharedPreferences.getInstance();
    for (var key in ["token", "name", "email", 'id']) {
      if (preferences.containsKey(key)) preferences.remove(key);
    }
  }
}
