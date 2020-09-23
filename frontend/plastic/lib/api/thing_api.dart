import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:plastic/api/account_api.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_get_response.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/thing.dart';

class ThingApi {
  static final ThingApi _singleton = ThingApi._internal();

  factory ThingApi() {
    return _singleton;
  }

  ThingApi._internal();

  /// Get all of a User's things.
  Future<ApiGetResponse<List<Thing>>> getThingsByUser() async {
    if (!await AccountApi().hasValidToken())
      return ApiGetResponse<List<Thing>>(
          getResult: List<Thing>(),
          successful: false,
          message: 'Please log in.');
    final response = await http.get(
      Api.getRoute(Routes.thingsByUser),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
    );
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

  Future<ApiResponse> saveThing(Thing thing) async {
    if (!await AccountApi().hasValidToken())
      return ApiResponse(successful: false, message: 'Please log in.');
    final response = await http.post(
      Api.getRoute(Routes.saveThing),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
      body: thing.toJson(),
    );
    return ApiResponse(
        successful: response.statusCode == 201, message: response.reasonPhrase);
  }

  Future<ApiResponse> deleteThing(Thing thing) async {
    if (!await AccountApi().hasValidToken())
      return ApiResponse(successful: false, message: 'Please log in.');

    final response = await http.post(
      Api.getRoute(Routes.deleteThing),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
      body: json.encode({'id': thing.id}),
    );
    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }
}
