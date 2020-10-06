import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:plastic/api/account_api.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/api/invalid_api_request_exception.dart';
import 'package:plastic/model/api/api_get_response.dart';
import 'package:plastic/model/api/api_post_response.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/widgets/components/loading_modal.dart';

class TemplateApi {
  static final TemplateApi _singleton = TemplateApi._internal();

  factory TemplateApi() {
    return _singleton;
  }

  TemplateApi._internal();

  /// Get a single template by id.
  Future<ApiGetResponse<Template>> getTemplateById(
      BuildContext context, String templateId) async {
    var validTokenResult = await AccountApi().hasValidToken();
    if (validTokenResult != null)
      return ApiGetResponse<Template>(
          message: validTokenResult.message, successful: false);
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );
    final response = await http.get(
      Api.getRoute(Routes.templateById) + templateId,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
    ).timeout(Api.timeout,
        onTimeout: () => http.Response("Servers not responding", 408));
    Navigator.pop(context);
    if (response.statusCode != 200) {
      throw new HttpException(json.decode(response.body)['error']);
    }
    return new ApiGetResponse<Template>(
        getResult: Template.fromJson(json.decode(response.body)));
  }

  /// Get all of a User's templates.
  Future<ApiGetResponse<List<Template>>> getTemplatesByUser(
      BuildContext context) async {
    var validTokenResult = await AccountApi().hasValidToken();
    if (validTokenResult != null)
      return ApiGetResponse<List<Template>>(
          message: validTokenResult.message, successful: false);
    if (context != null)
      showDialog(
        context: context,
        builder: (context) => LoadingModal(),
      );
    final response = await http.get(
      Api.getRoute(Routes.templatesByUser),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
    ).timeout(Api.timeout,
        onTimeout: () => http.Response("Servers not responding", 408));
    if (context != null) Navigator.pop(context);
    if (response.statusCode != 200) {
      throw new HttpException(json.decode(response.body)['error']);
    }
    var templates = new List<Template>();
    json
        .decode(response.body)
        .forEach((v) => templates.add(new Template.fromJson(v)));
    return ApiGetResponse<List<Template>>(
        successful: true, message: response.reasonPhrase, getResult: templates);
  }

  Future<ApiPostResponse<List<Thing>>> saveTemplate(BuildContext context,
      Template template, List<Thing> updatedThings) async {
    var validTokenResult = await AccountApi().hasValidToken();
    if (validTokenResult != null)
      return ApiPostResponse<List<Thing>>(
          message: validTokenResult.message, successful: false);
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );
    final response = await http
        .post(
          Api.getRoute(Routes.saveTemplate),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: AccountApi().authHeader(),
          },
          body: jsonEncode({
            "template": template,
            "updatedThings": updatedThings,
          }),
        )
        .timeout(Api.timeout,
            onTimeout: () => http.Response("Servers not responding", 408));
    Navigator.pop(context);
    List<Thing> affectedThings;

    if (response.statusCode == 422) {
      Map body = jsonDecode(response.body);
      if (body.containsKey("affectedThings")) {
        affectedThings = body["affectedThings"]
            .map<Thing>((thing) => Thing.fromJsonMap(thing))
            .toList();
      } else {
        return Future.error(InvalidApiRequestException(
            body["templateErrors"].map<String>((i) => i.toString()).toList()));
      }
    }

    return ApiPostResponse<List<Thing>>(
        postResult: affectedThings,
        successful: response.statusCode == 201,
        message: response.reasonPhrase);
  }

  Future<ApiResponse> deleteTemplate(
      BuildContext context, Template template) async {
    var validTokenResult = await AccountApi().hasValidToken();
    if (validTokenResult != null) return validTokenResult;
    showDialog(
      context: context,
      builder: (context) => LoadingModal(),
    );
    final response = await http
        .post(
          Api.getRoute(Routes.deleteTemplate),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: AccountApi().authHeader(),
          },
          body: json.encode({'id': template.id}),
        )
        .timeout(Api.timeout,
            onTimeout: () => http.Response("Servers not responding", 408));
    Navigator.pop(context);
    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }
}
