import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/api/log_in_response.dart';
import 'package:plastic/model/preference_manager.dart';
import 'package:plastic/widgets/components/loading_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountApi {
  static final AccountApi _singleton = AccountApi._internal();

  factory AccountApi() {
    return _singleton;
  }

  AccountApi._internal();

  // final int _tokenCacheTtl = int.parse(DotEnv().env['TOKEN_CACHE_TTL']);
  // int _tokenCacheExpirationTime = 0;
  String token;
  String _userId;

  String authHeader() {
    _fetchToken();
    return 'Bearer $token';
  }

  String get userId => _userId;

  bool _fetchToken() {
    if (token == null) {
      try {
        var preferences = PreferenceManager().get();
        token = preferences.getString("token");
        _userId = preferences.getString("id");
      } on Exception {
        token = null;
      }
    }
    return token != null;
  }

  /// Attempts to log in with the given credentials. Returns a token if successful, otherwise throws an exception.
  Future<LogInResponse> login(
      BuildContext context, String email, String password) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );

    final response = await http
        .post(
          Api.getRoute(Routes.login),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode({
            "email": email.trim(),
            "password": password,
          }),
        )
        .timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    ApiException.throwErrorMessage(response.statusCode);

    var logInResponse = LogInResponse.fromJson(json.decode(response.body),
        successful: true, message: response.reasonPhrase);
    _userId = logInResponse.user.id;
    return logInResponse;
  }

  /// Register a new user
  Future<LogInResponse> register(
      BuildContext context, String email, String password, String name) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );

    final response = await http
        .post(
          Api.getRoute(Routes.register),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode({
            "email": email.trim(),
            "name": name.trim(),
            "password": password,
          }),
        )
        .timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    ApiException.throwErrorMessage(response.statusCode);

    var logInResponse = new LogInResponse.fromJson(json.decode(response.body));
    _userId = logInResponse.user.id;
    return logInResponse;
  }

  /// Log out just this token
  Future<ApiResponse> logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );
    await clearPrefs();

    final response = await http.post(
      Api.getRoute(Routes.logout),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: authHeader(),
      },
    ).timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    ApiException.throwErrorMessage(response.statusCode);
    token = null;
    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }

  /// Log out all tokens
  Future<ApiResponse> logoutAll(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );
    await clearPrefs();

    final response = await http.post(
      Api.getRoute(Routes.logoutAll),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: authHeader(),
      },
    ).timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    ApiException.throwErrorMessage(response.statusCode);
    token = null;
    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }

  /// Clear out any saved user information from persistent storage
  Future<void> clearPrefs() async {
    var preferences = PreferenceManager().get();
    for (var key in ["token", "name", "email", 'id']) {
      if (preferences.containsKey(key)) preferences.remove(key);
    }
    await PreferenceManager().loadPreferences();
  }
}
