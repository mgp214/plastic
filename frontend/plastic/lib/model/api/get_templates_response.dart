import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/template.dart';

class GetTemplatesResponse extends ApiResponse {
  final List<Template> things;

  GetTemplatesResponse({this.things, bool successful, String message})
      : super(successful: successful, message: message);
}
