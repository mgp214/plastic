import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/account/log_in_page.dart';

class Notifier {
  static Future<dynamic> notify(BuildContext context,
          {String message, Color color}) =>
      Flushbar(
        backgroundColor: Motif.lightBackground,
        flushbarPosition: FlushbarPosition.TOP,
        messageText: Text(
          message,
          style: Motif.contentStyle(Sizes.Notification, color ?? Motif.black),
        ),
        duration: Constants.snackDuration,
      ).show(context);

  static void handleApiError(BuildContext context, ApiException e) {
    switch (e.statusCode) {
      case 401:
        Navigator.popUntil(context, ModalRoute.withName('home'));
        break;
      case 403:
        Api.account.clearPrefs().then((value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LogInPage()));
        });
        break;
    }
    notify(context, message: e.message, color: Motif.negative);
  }
}
