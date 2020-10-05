import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/api/log_in_response.dart';
import 'package:plastic/widgets/loading_modal.dart';
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

  Future<ApiResponse> hasValidToken() async {
    if (!await _fetchToken())
      return ApiResponse(successful: false, message: "You aren't logged in.");
    if (_tokenCacheExpirationTime > DateTime.now().millisecondsSinceEpoch)
      return null;
    var checkTokenResponse = await checkToken(token);
    return getErrorMessage(checkTokenResponse);
  }

  ApiResponse getErrorMessage(int code) {
    switch (code) {
      case 401:
        return ApiResponse(
            successful: false, message: "You're not allowed to do that.");
      case 408:
        return Api.timeoutResponse;
    }

    return null;
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
        .timeout(Api.timeout,
            onTimeout: () => http.Response("Servers not responding", 408));
    Navigator.pop(context);

    if (response.statusCode == 401)
      return LogInResponse(
          successful: false,
          message: "You entered incorrect information. Try again!");
    var errorResponse = getErrorMessage(response.statusCode);
    if (errorResponse != null)
      return LogInResponse(successful: false, message: errorResponse.message);

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
        .timeout(Api.timeout,
            onTimeout: () => http.Response("Servers not responding", 408));
    Navigator.pop(context);

    var errorResponse = getErrorMessage(response.statusCode);
    if (errorResponse != null)
      return LogInResponse(successful: false, message: errorResponse.message);
    var logInResponse = new LogInResponse.fromJson(json.decode(response.body));
    _userId = logInResponse.user.id;
    return logInResponse;
  }

  /// Check if a given token is valid
  Future<int> checkToken(String token) async {
    if (token == null) return 401;

    final response = await http
        .post(
          Api.getRoute(Routes.checkToken),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode({"token": token}),
        )
        .timeout(Api.timeout,
            onTimeout: () => http.Response("Servers not responding", 408));

    var result = response.statusCode;

    if (result != 200) {
      await clearPrefs();
    } else {
      _tokenCacheExpirationTime =
          DateTime.now().millisecondsSinceEpoch + _tokenCacheTtl;
    }
    return result;
  }

  /// Log out just this token
  Future<ApiResponse> logout(BuildContext context) async {
    if (!await _fetchToken())
      return ApiResponse(successful: false, message: 'Please log in.');
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );
    Navigator.pop(context);
    await clearPrefs();
    final response = await http.post(
      Api.getRoute(Routes.logout),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: authHeader(),
      },
    ).timeout(Api.timeout,
        onTimeout: () => http.Response("Servers not responding", 408));
    token = null;
    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }

  /// Log out all tokens
  Future<ApiResponse> logoutAll(BuildContext context) async {
    if (!await _fetchToken())
      return ApiResponse(successful: false, message: 'Please log in.');
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );
    await clearPrefs();
    Navigator.pop(context);
    final response = await http.post(
      Api.getRoute(Routes.logoutAll),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: authHeader(),
      },
    ).timeout(Api.timeout,
        onTimeout: () => http.Response("Servers not responding", 408));
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
