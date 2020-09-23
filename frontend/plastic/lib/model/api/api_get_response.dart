import 'package:plastic/model/api/api_response.dart';

class ApiGetResponse<T> extends ApiResponse {
  final T getResult;

  ApiGetResponse({this.getResult, bool successful, String message})
      : super(successful: successful, message: message);
}
