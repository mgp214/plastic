import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/constants.dart';

class NotificationUtilities {
  static Future<dynamic> notify(BuildContext context,
          {String message, Color color}) =>
      Flushbar(
        backgroundColor: Motif.background,
        flushbarPosition: FlushbarPosition.TOP,
        messageText: Text(
          message,
          style: Motif.contentStyle(Sizes.Notification, color ?? Motif.black),
        ),
        duration: Constants.snackDuration,
      ).show(context);
}
