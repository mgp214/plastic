import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/thing.dart';

class GetThingsResponse extends ApiResponse {
  final List<Thing> things;

  GetThingsResponse({this.things, bool successful, String message})
      : super(successful: successful, message: message);
}
