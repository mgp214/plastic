import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:plastic/api/account_api.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/api/api_get_response.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/widgets/components/loading_modal.dart';

class ViewApi {
  static final ViewApi _singleton = ViewApi._internal();

  factory ViewApi() {
    return _singleton;
  }

  ViewApi._internal();

  Future<ApiGetResponse<List<View>>> getViewsByUser(
      BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );

    final response = await http.get(Api.getRoute(Routes.viewsByUser), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: AccountApi().authHeader(),
    }).timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    var error = ApiException.throwErrorMessage(response.statusCode);
    if (error != null) return Future.error(error);

    var views = List<View>();
    if (response.statusCode == 200) {
      json.decode(response.body).forEach((v) => views.add(View.fromJsonMap(v)));
    }

    return ApiGetResponse<List<View>>(
        getResult: views,
        successful: response.statusCode == 200,
        message: response.reasonPhrase);
  }

  Future<ApiResponse> saveView(BuildContext context, View view) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );

    log(view.toJson());

    final response = await http
        .post(
          Api.getRoute(Routes.saveView),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: AccountApi().authHeader(),
          },
          body: view.toJson(),
        )
        .timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    var error = ApiException.throwErrorMessage(response.statusCode);
    if (error != null) return Future.error(error);

    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }
}
