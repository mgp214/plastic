import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:plastic/api/account_api.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_get_response.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/template.dart';

class TemplateApi {
  static final TemplateApi _singleton = TemplateApi._internal();

  factory TemplateApi() {
    return _singleton;
  }

  TemplateApi._internal();

  /// Get a single template by id.
  Future<ApiGetResponse<Template>> getTemplateById(String templateId) async {
    if (!await AccountApi().hasValidToken())
      return ApiGetResponse<Template>(
          successful: false, message: 'Please log in.');

    final response = await http.get(
      Api.getRoute(Routes.templateById) + templateId,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
    );
    if (response.statusCode != 200) {
      throw new HttpException(json.decode(response.body)['error']);
    }
    return new ApiGetResponse<Template>(
        getResult: Template.fromJson(json.decode(response.body)));
  }

  /// Get all of a User's templates.
  Future<ApiGetResponse<List<Template>>> getTemplatesByUser() async {
    if (!await AccountApi().hasValidToken())
      return ApiGetResponse<List<Template>>(
          successful: false, message: 'Please log in.');
    final response = await http.get(
      Api.getRoute(Routes.templatesByUser),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
    );
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

  Future<ApiResponse> saveTemplate(Template template) async {
    if (!await AccountApi().hasValidToken())
      return ApiResponse(successful: false, message: 'Please log in.');
    final response = await http.post(
      Api.getRoute(Routes.saveTemplate),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
      body: template.toJson(),
    );
    return ApiResponse(
        successful: response.statusCode == 201, message: response.reasonPhrase);
  }

  Future<ApiResponse> deleteTemplate(Template template) async {
    if (!await AccountApi().hasValidToken())
      return ApiResponse(successful: false, message: 'Please log in.');

    final response = await http.post(
      Api.getRoute(Routes.deleteTemplate),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: AccountApi().authHeader(),
      },
      body: json.encode({'id': template.id}),
    );
    return ApiResponse(
        successful: response.statusCode == 200, message: response.reasonPhrase);
  }
}
