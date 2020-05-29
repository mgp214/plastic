import 'package:flutter/material.dart';

class User {
  final String name;
  final String email;
  final String id;
  final int v;

  User({@required this.name, @required this.email, @required this.id, this.v});

  static User fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      id: json['_id'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['_id'] = this.id;
    data['__v'] = this.v;
    return data;
  }
}
