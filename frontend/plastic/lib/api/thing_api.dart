import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:plastic/api/account_api.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/api/api_get_response.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/widgets/components/loading_modal.dart';

class ThingApi {
  static final ThingApi _singleton = ThingApi._internal();

  factory ThingApi() {
    return _singleton;
  }

  ThingApi._internal();

  /// Get all of a User's things.
  Future<ApiGetResponse<List<Thing>>> getThingsByUser(
      BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );

    final response = await http.get(
      Api.getRoute(Routes.thingsByUser),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
    ).timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    var error = ApiException.throwErrorMessage(response.statusCode);
    if (error != null) return Future.error(error);

    var things = new List<Thing>();
    if (response.statusCode == 200) {
      json
          .decode(response.body)
          .forEach((v) => things.add(new Thing.fromJsonMap(v)));
    }

    return ApiGetResponse<List<Thing>>(
        getResult: things,
        successful: response.statusCode == 200,
        message: response.reasonPhrase);
  }

  Future<ApiResponse> saveThing(BuildContext context, Thing thing) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );

    final response = await http
        .post(
          Api.getRoute(Routes.saveThing),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: AccountApi().authHeader(),
          },
          body: thing.toJson(),
        )
        .timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    var error = ApiException.throwErrorMessage(response.statusCode);
    if (error != null) return Future.error(error);

    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }

  Future<ApiResponse> deleteThing(BuildContext context, Thing thing) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );

    final response = await http
        .post(
          Api.getRoute(Routes.deleteThing),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: AccountApi().authHeader(),
          },
          body: json.encode({'id': thing.id}),
        )
        .timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    var error = ApiException.throwErrorMessage(response.statusCode);
    if (error != null) return Future.error(error);

    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }

  Future<ApiResponse> getThingsMatching(
      BuildContext context, ThingCondition condition) async {
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );

    final response = await http
        .post(
          Api.getRoute(Routes.thingsMatching),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: AccountApi().authHeader(),
          },
          body: jsonEncode(condition.toJson()),
        )
        .timeout(Api.timeout, onTimeout: () => ApiException.timeoutResponse);

    Navigator.pop(context);
    var error = ApiException.throwErrorMessage(response.statusCode);
    if (error != null) return Future.error(error);

    var things = new List<Thing>();
    if (response.statusCode == 200) {
      json
          .decode(response.body)
          .forEach((v) => things.add(new Thing.fromJsonMap(v)));
    }

    return ApiGetResponse<List<Thing>>(
        getResult: things,
        successful: response.statusCode == 200,
        message: response.reasonPhrase);
  }
}
