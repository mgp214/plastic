import 'package:plastic/model/api/api_response.dart';

import '../user.dart';

class LogInResponse extends ApiResponse {
  User user;
  String token;

  LogInResponse({this.user, this.token, bool successful, String message})
      : super(successful: successful, message: message);

  LogInResponse.fromJson(Map<String, dynamic> json,
      {bool successful, String message})
      : super(successful: successful, message: message) {
    user = json.containsKey('user') ? User.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}
