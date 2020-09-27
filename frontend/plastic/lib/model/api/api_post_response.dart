import 'package:plastic/model/api/api_response.dart';

class ApiPostResponse<T> extends ApiResponse {
  final T postResult;

  ApiPostResponse({this.postResult, bool successful, String message})
      : super(successful: successful, message: message);
}
