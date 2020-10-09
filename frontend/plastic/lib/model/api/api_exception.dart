import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  static final http.Response timeoutResponse = http.Response("timeout", 408);

  ApiException({this.statusCode, this.message});

  /// throws an ApiException if there was a problem. Otherwise returns null.
  static ApiException throwErrorMessage(int code) {
    switch (code) {
      case 401:
        return ApiException(
            statusCode: code, message: "You don't have permission to do that.");
        break;
      case 403:
        return ApiException(
            statusCode: code, message: "Your credentials were invalid.");
        break;
      case 408:
        return ApiException(
            statusCode: code, message: "The server didn't respond.");
        break;
      case 500:
        return ApiException(
            statusCode: code,
            message: "The server encountered an unexpected problem.");
        break;
    }
    return null;
  }
}
