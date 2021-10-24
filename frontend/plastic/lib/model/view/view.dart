import 'dart:convert';

import 'package:plastic/model/view/frame.dart';

class View {
  Frame root;
  String name;
  String id;
  String userId;

  View({
    this.root,
    this.id,
    this.userId,
    this.name,
  }) {
    if (name == null) name = "";
  }

  View.fromJsonMap(Map<String, dynamic> jsonMap) {
    if (jsonMap["root"] != null) {
      root = Frame.fromJson(jsonMap["root"], null);
      name = jsonMap["name"];
      id = jsonMap["_id"];
      userId = jsonMap["userId"];
    }
  }

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = name;
    if (id != null) data["_id"] = id;
    data["userId"] = userId;
    data["root"] = root.toJson();

    return jsonEncode(data);
  }
}
